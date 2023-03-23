param clusterName string
param logworkspaceid string
param privateDNSZoneId string
param aadGroupdIds array
param subnetId string
param identity object
// param appGatewayResourceId string
//param kubernetesVersion string
param location string = resourceGroup().location
param availabilityZones array
param enableAutoScaling bool
param autoScalingProfile object
param podCidr string // = '172.17.0.0/16'
param upgradeChannel string
param nodeOSUpgradeChannel string

param systemNodePoolReplicas int
param userNodePool1Replicas int
param userNodePool2Replicas int

param vmSize string

@allowed([
  'azure'
  'kubenet'
])
param networkPlugin string = 'kubenet'
//param appGatewayIdentityResourceId string

resource aksCluster 'Microsoft.ContainerService/managedClusters@2022-01-02-preview' = {
  name: clusterName
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: identity
  }
  properties: {
    //kubernetesVersion: kubernetesVersion
    nodeResourceGroup: '${clusterName}-aksInfraRG'
    dnsPrefix: '${clusterName}aks'
    agentPoolProfiles: [
      {
        enableAutoScaling: enableAutoScaling
        name: 'systempool'
        availabilityZones: !empty(availabilityZones) ? availabilityZones : null
        mode: 'System'
        enableEncryptionAtHost: true
        count: systemNodePoolReplicas
        minCount: enableAutoScaling ? 1 : null
        maxCount: enableAutoScaling ? 3 : null
        vmSize: vmSize
        osDiskSizeGB: 30
        type: 'VirtualMachineScaleSets'
        vnetSubnetID: subnetId
      }
      {
        enableAutoScaling: enableAutoScaling
        name: 'usernp1'
        availabilityZones: !empty(availabilityZones) ? availabilityZones : null
        mode: 'User'
        enableEncryptionAtHost: true
        count: userNodePool1Replicas
        minCount: enableAutoScaling ? 1 : null
        maxCount: enableAutoScaling ? 3 : null
        vmSize: vmSize
        osDiskSizeGB: 30
        type: 'VirtualMachineScaleSets'
        vnetSubnetID: subnetId
      }
      {
        enableAutoScaling: enableAutoScaling
        name: 'usernp2'
        availabilityZones: !empty(availabilityZones) ? availabilityZones : null
        mode: 'User'
        enableEncryptionAtHost: true
        count: userNodePool2Replicas
        minCount: enableAutoScaling ? 1 : null
        maxCount: enableAutoScaling ? 3 : null
        vmSize: vmSize
        osDiskSizeGB: 30
        type: 'VirtualMachineScaleSets'
        vnetSubnetID: subnetId
      }
    ]
    autoScalerProfile: enableAutoScaling ? autoScalingProfile : null

    autoUpgradeProfile: {
      nodeOSUpgradeChannel: nodeOSUpgradeChannel
      upgradeChannel: upgradeChannel
    }
    
    disableLocalAccounts: false

    networkProfile: networkPlugin == 'azure' ? {
      networkPlugin: 'azure'
      outboundType: 'userDefinedRouting'
      dockerBridgeCidr: '172.16.1.1/30'
      dnsServiceIP: '192.168.100.10'
      serviceCidr: '192.168.100.0/24'
      networkPolicy: 'calico'
    }:{
      networkPlugin: 'kubenet'
      outboundType: 'userDefinedRouting'
      dockerBridgeCidr: '172.16.1.1/30'
      dnsServiceIP: '192.168.100.10'
      serviceCidr: '192.168.100.0/24'
      networkPolicy: 'calico'
      podCidr: podCidr
    }
    apiServerAccessProfile: {
      enablePrivateCluster: true
      privateDNSZone: privateDNSZoneId
      enablePrivateClusterPublicFQDN: false
    }
    enableRBAC: true
    aadProfile: {
      adminGroupObjectIDs: aadGroupdIds
      enableAzureRBAC: true
      managed: true
      tenantID: subscription().tenantId
    }
    addonProfiles: {
      omsagent: {
        config: {
          logAnalyticsWorkspaceResourceID: logworkspaceid
        }
        enabled: true
      }
      azurepolicy: {
        enabled: true
      }
      //Enable the following two configurations for Workload identity and OIDC Issuer
      // Features are currently in preview
      // workloadIdentity: {
      //   enabled: true
      // }
      // oidcIssuerProfile: {
      //   enabled: true
      // }


      // ingressApplicationGateway: {
      //   enabled: true
      //   config: {
      //     applicationGatewayId: appGatewayResourceId
      //     effectiveApplicationGatewayId: appGatewayResourceId
      //   }
      // }
      azureKeyvaultSecretsProvider: {
        enabled: true
      }
    }
  }
}

output kubeletIdentity string = aksCluster.properties.identityProfile.kubeletidentity.objectId
//output ingressIdentity string = aksCluster.properties.addonProfiles.ingressApplicationGateway.identity.objectId
output keyvaultaddonIdentity string = aksCluster.properties.addonProfiles.azureKeyvaultSecretsProvider.identity.objectId

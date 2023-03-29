# Deploy Template

This template deploys a secure AKS baseline cluster with the following high-level setup:
- 3 node pools (2 user node pools, 1 system node pool)
- Security and Private networking features enabled
- Expects existing vnet, route table, keyvault, and log analytics workspace which can exist in separate resource groups than the deployed AKS cluster.

## Prep:
- Create a resource group to be used, if there is not already one created
- Create AAD groups for Devs and Admins cluster access, these will be used as PrincipalID paramteres in the template.
- Enable host encryption feature:
  `az feature register --namespace  Microsoft.Compute --name EncryptionAtHost`
- Once registration is complete, run: `az provider register -n Microsoft.Compute`
- Requires existing vnet/subnet with udr set on subnet

## Deploy
1. Update parameters-dev.json template for Dev deployment, as an example
2. Deploy Template, update location to match desired cluster region:

**Dev Deployment:**
```
az deployment sub create --template-file AKS-Cluster-Bicep/main.bicep --parameters @AKS-Cluster-Bicep/parameters-dev.json --location eastus2
```
**Prod Deployment:**
```dotnetcli
az deployment sub create --template-file AKS-Cluster-Bicep/main.bicep --parameters @AKS-Cluster-Bicep/parameters-prod.json --location westus3
```


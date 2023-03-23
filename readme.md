## Deploy Template

1. Prep:
- Create a resource group to be used, if there is not already one created
- Create AAD groups for Devs and Admins cluster access, these will be used as PrincipalID paramteres in the template.
- Enable host encryption feature:
  `az feature register --namespace  Microsoft.Compute --name EncryptionAtHost`
- Once registration is complete, run: `az provider register -n Microsoft.Compute`
- Requires existing vnet/subnet with udr set on subnet
2. Update parameters-main.json template
3. Deploy Template, update location to match desired cluster region:
```
az deployment sub create --template-file AKS-Cluster-Bicep/main.bicep --parameters @AKS-Cluster-Bicep/parameters-main.json --location eastus2
```
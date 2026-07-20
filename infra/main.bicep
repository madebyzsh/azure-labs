@description('Deployment environment. Drives resource naming.')
param tags object = {
  environment: environment
  owner: 'sohaib'
  managedBy: 'bicep'
}
@allowed([
  'dev'
  'prod'
])
param environment string = 'dev'
param location string = resourceGroup().location

module network 'modules/network.bicep' = {
  name: 'network-deployment'
  params: {
    location: location
    environment: environment
    tags: tags
  }
}

module storage 'modules/storage.bicep' = {
  name: 'storage-deployment'
  params: {
    location: location
    tags: tags
  }
}

module keyvault 'modules/keyvault.bicep' = {
  name: 'keyvault-deployment'
  params: {
    location: location
    tags: tags
  }
}

output workloadSubnetId string = network.outputs.workloadSubnetId
output endpointsSubnetId string = network.outputs.endpointsSubnetId
output storageAccountName string = storage.outputs.storageAccountName
output keyVaultName string = keyvault.outputs.keyVaultName
output keyVaultId string = keyvault.outputs.keyVaultId
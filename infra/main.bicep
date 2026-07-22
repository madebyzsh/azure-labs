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

@description('Source IP allowed to SSH. Changes when Cloud Shell restarts.')
param allowedSshSourceIp string

module network 'modules/network.bicep' = {
  name: 'network-deployment'
  params: {
    location: location
    environment: environment
    tags: tags
    allowedSshSourceIp: allowedSshSourceIp
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

module privateEndpoint 'modules/privateendpoint.bicep' = {
  name: 'privateendpoint-deployment'
  params: {
    location: location
    environmentName: environment
    subnetId: network.outputs.endpointsSubnetId
    vnetId: network.outputs.vnetId
    storageAccountId: storage.outputs.storageAccountId
    storageAccountName: storage.outputs.storageAccountName
  }
}

module aks 'modules/aks.bicep' = {
  name: 'aks-deployment'
  params: {
    location: location
    environmentName: environment
    tags: tags
    vnetName: network.outputs.vnetName
    aksSubnetName: network.outputs.aksSubnetName
  }
}

output workloadSubnetId string = network.outputs.workloadSubnetId
output endpointsSubnetId string = network.outputs.endpointsSubnetId
output storageAccountName string = storage.outputs.storageAccountName
output keyVaultName string = keyvault.outputs.keyVaultName
output keyVaultId string = keyvault.outputs.keyVaultId
output privateDnsZoneName string = privateEndpoint.outputs.privateDnsZoneName
output privateEndpointName string = privateEndpoint.outputs.privateEndpointName
output aksClusterName string = aks.outputs.clusterName
output aksNodeResourceGroup string = aks.outputs.nodeResourceGroup
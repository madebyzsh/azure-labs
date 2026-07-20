param location string = resourceGroup().location

module network 'modules/network.bicep' = {
  name: 'network-deployment'
  params: {
    location: location
  }
}
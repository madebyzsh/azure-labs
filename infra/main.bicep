param location string = resourceGroup().location

module network 'modules/network.bicep' = {
  name: 'network-deployment'
  params: {
    location: location
  }
}

output workloadSubnetId string = network.outputs.workloadSubnetId
output endpointsSubnetId string = network.outputs.endpointsSubnetId
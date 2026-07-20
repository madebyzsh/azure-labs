// A parameter = an input you can change without editing the file
param location string = resourceGroup().location

// A resource block = "make this thing exist"
resource vnet 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: 'vnet-lab'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.10.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'snet-workload'
        properties: {
          addressPrefix: '10.10.1.0/24'
        }
      }
      {
        name: 'snet-endpoints'
        properties: {
          addressPrefix: '10.10.2.0/24'
        }
      }
    ]
  }
}
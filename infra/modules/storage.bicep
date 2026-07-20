param location string
param tags object

@description('Prefix for the storage account name; a unique suffix is appended.')
param namePrefix string = 'stlab'

resource storage 'Microsoft.Storage/storageAccounts@2024-01-01' = {
  name: '${namePrefix}${uniqueString(resourceGroup().id)}'
  location: location
  tags: tags
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    publicNetworkAccess: 'Disabled'
    allowBlobPublicAccess: false
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
  }
}

output storageAccountName string = storage.name
output storageAccountId string = storage.id
param location string = resourceGroup().location

@allowed(['dev','prod'])
param environment string = 'dev'

var storageName = 'stazdo${uniqueString(resourceGroup().id)}'

resource sa 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageName
  location: location
  sku: { name: 'Standard_LRS' }
  kind: 'StorageV2'
  properties: {
    allowBlobPublicAccess: false
    minimumTlsVersion: 'TLS1_2'
  }
  tags: { env: environment, lab: 'azdo' }
}

output storageAccountName string = sa.name

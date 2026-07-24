param location string = resourceGroup().location
param owner string = 'sohaib'

resource sa 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: 'stcidemo${uniqueString(resourceGroup().id)}'
  location: location
  sku: { name: 'Standard_LRS' }
  kind: 'StorageV2'
  tags: { owner: owner, purpose: 'cicd-lab' }
  properties: {
    allowBlobPublicAccess: false
    minimumTlsVersion: 'TLS1_2'
  }
}

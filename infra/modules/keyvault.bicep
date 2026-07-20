param location string
param tags object

@description('Prefix for the Key Vault name; a unique suffix is appended.')
param namePrefix string = 'kv-lab'

resource keyvault 'Microsoft.KeyVault/vaults@2024-04-01-preview' = {
  name: '${namePrefix}-${uniqueString(resourceGroup().id)}'
  location: location
  tags: tags
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    enableRbacAuthorization: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 7
    publicNetworkAccess: 'Disabled'
    networkAcls: {
      defaultAction: 'Deny'
      bypass: 'AzureServices'
    }
  }
}

output keyVaultName string = keyvault.name
output keyVaultId string = keyvault.id
param storageAccountName string
param location string
param skuName string

@description('Tags for the Storage Account')
param tags object = {}

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: storageAccountName
  location: location
  kind: 'StorageV2'
  sku: {
    name: skuName
  }
  properties:{
    networkAcls:{
      bypass: 'AzureServices'
      virtualNetworkRules: []
      ipRules: []
      defaultAction: 'Allow'
    }
    supportsHttpsTrafficOnly: true
    encryption: {
      keySource: 'Microsoft.Storage'
      services: {
        file:{
          keyType: 'Account'
          enabled: true
        }
        blob:{
          keyType: 'Account'
          enabled: true
        }
      }
    }
  }
  tags: tags
}

resource saFileService 'Microsoft.Storage/storageAccounts/fileServices@2022-05-01' = {
  parent: storageAccount
  name: 'default'
  properties: {
    shareDeleteRetentionPolicy: {
      enabled: true
      days: 7
    }
  }
}
resource saFileShareTracking 'Microsoft.Storage/storageAccounts/fileServices/shares@2022-05-01' = {
  parent: saFileService
  name: 'scripts'
  properties: {
    accessTier: 'Hot'
    shareQuota: 100
    enabledProtocols: 'SMB'
  }
}

output blobUri string = storageAccount.properties.primaryEndpoints.blob

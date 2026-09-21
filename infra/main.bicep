param location string = resourceGroup().location
resource storage 'Microsoft.Storage/storageAccounts@2023-05-01' = {
 name: 'st${uniqueString(resourceGroup().id)}'
 location: location
 kind: 'StorageV2'
 sku: { name: 'Standard_LRS' }
 properties: {
  minimumTlsVersion: 'TLS1_2'
  supportsHttpsTrafficOnly: true
  allowBlobPublicAccess: false
  allowSharedKeyAccess: false
  publicNetworkAccess: 'Disabled'
 }
}
output storageName string = storage.name
output storageId string = storage.id

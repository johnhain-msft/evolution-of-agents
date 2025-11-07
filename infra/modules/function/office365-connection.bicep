// Office 365 API Connection for Logic Apps Standard
param location string = resourceGroup().location
param connectionName string

// Create Office 365 connection using managed identity
// Note: The connection is created but OAuth consent may be required on first use
resource office365Connection 'Microsoft.Web/connections@2016-06-01' = {
  name: connectionName
  location: location
  properties: {
    displayName: 'Office 365 Connection'
    api: {
      id: subscriptionResourceId('Microsoft.Web/locations/managedApis', location, 'office365')
    }
  }
}

// Output connection details
output connectionId string = office365Connection.id
output connectionName string = office365Connection.name
// connectionRuntimeUrl accessed via reference() with 'full' parameter
output connectionRuntimeUrl string = reference(office365Connection.id, '2016-06-01', 'full').properties.connectionRuntimeUrl

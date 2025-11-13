// Office 365 API Connection for Logic Apps Standard
param location string = resourceGroup().location
param connectionName string
param logicAppPrincipalId string

// Create Office 365 connection using managed identity
// IMPORTANT: Office365 connector requires manual OAuth consent
// The connection is created but will fail with 401 Unauthorized until authorized
// To authorize: Azure Portal → Resource Group → office365v2 connection → Edit API connection → Authorize
// This is a limitation of Office365 connector - it cannot be fully automated with service principals
// See: https://learn.microsoft.com/en-us/azure/logic-apps/authenticate-with-managed-identity
// CRITICAL: kind 'V2' is required for connectionRuntimeUrl to be available
resource office365Connection 'Microsoft.Web/connections@2018-07-01-preview' = {
  name: connectionName
  location: location
  kind: 'V2'
  properties: {
    displayName: 'Office 365 Connection'
    api: {
      id: subscriptionResourceId('Microsoft.Web/locations/managedApis', location, 'office365')
    }
  }
}

resource accessPolicy 'Microsoft.Web/connections/accessPolicies@2016-06-01' = {
  name: guid(office365Connection.id, logicAppPrincipalId)
  parent: office365Connection
  location: location
  properties: {
    principal: {
      type: 'ActiveDirectory'
      identity: {
        tenantId: subscription().tenantId
        objectId: logicAppPrincipalId
      }
    }
  }
}

// Output connection details
output connectionId string = office365Connection.id
output connectionName string = office365Connection.name
// connectionRuntimeUrl is available with kind: 'V2' and API version 2018-07-01-preview
output connectionRuntimeUrl string = reference(office365Connection.id, '2018-07-01-preview', 'full').properties.connectionRuntimeUrl

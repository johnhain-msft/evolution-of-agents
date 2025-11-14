param foundry_name string
param location string
param project_name string
param project_description string
param display_name string
param managedIdentityId string = ''
param tags object = {}
@description('The resource ID of the existing AI resource.')
param existingAiResourceId string?
@description('The Kind of AI Service, can be "AzureOpenAI" or "AIServices"')
@allowed([
  'AzureOpenAI'
  'AIServices'
])
param existingAiKind string = 'AIServices'

param aiSearchName string = ''
param aiSearchServiceResourceGroupName string = ''
param aiSearchServiceSubscriptionId string = ''

param cosmosDBName string = ''
param cosmosDBSubscriptionId string = ''
param cosmosDBResourceGroupName string = ''

param azureStorageName string = ''
param azureStorageSubscriptionId string = ''
param azureStorageResourceGroupName string = ''
@description('Deprecated: Account-level CapabilityHost removed to prevent 409 Conflict. Kept for backwards compatibility.')
param createHubCapabilityHost bool = false

param bingAccountId string = ''
param bingAccountEndpoint string = ''
param resourceToken string

// --------------------------------------------------------------------------------------------------------------
// split managed identity resource ID to get the name
var identityParts = split(managedIdentityId, '/')
// get the name of the managed identity
var managedIdentityName = length(identityParts) > 0 ? identityParts[length(identityParts) - 1] : ''

resource identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-07-31-preview' existing = if (!empty(managedIdentityName)) {
  name: managedIdentityName
}

// Agent doesn't see the models when connection is on the Foundry level
@description('Set to true to use the AI Foundry connection for the project, false to use the project connection.')
param usingFoundryAiConnection bool = false
var byoAiProjectConnectionName = 'aiConnection-project-for-${project_name}'
var byoAiFoundryConnectionName = 'aiConnection-foundry-for-${foundry_name}'

// get subid, resource group name and resource name from the existing resource id
var existingAiResourceIdParts = split(existingAiResourceId ?? '', '/')
var existingAiResourceIdSubId = empty(existingAiResourceId) ? '' : existingAiResourceIdParts[2]
var existingAiResourceIdRgName = empty(existingAiResourceId) ? '' : existingAiResourceIdParts[4]
var existingAiResourceIdName = empty(existingAiResourceId) ? '' : existingAiResourceIdParts[8]

// Get the existing Azure AI resource
resource existingAiResource 'Microsoft.CognitiveServices/accounts@2023-05-01' existing = if (!empty(existingAiResourceId)) {
  scope: resourceGroup(existingAiResourceIdSubId, existingAiResourceIdRgName)
  name: existingAiResourceIdName
}

var isAiResourceValid = empty(existingAiResourceId) || (existingAiResource!.location == location ) ? true : fail('The existing AIServices resource must be in the same region as the location parameter and must exist. See: https://github.com/azure-ai-foundry/foundry-samples/tree/main/samples/microsoft/infrastructure-setup/42-basic-agent-setup-with-customization and https://learn.microsoft.com/en-us/azure/ai-foundry/agents/how-to/use-your-own-resources')

#disable-next-line BCP081
resource foundry 'Microsoft.CognitiveServices/accounts@2025-04-01-preview' existing = {
  name: foundry_name
  scope: resourceGroup()
}

resource searchService 'Microsoft.Search/searchServices@2024-06-01-preview' existing = if (!empty(aiSearchName)) {
  name: aiSearchName
  scope: resourceGroup(aiSearchServiceSubscriptionId, aiSearchServiceResourceGroupName)
}
resource cosmosDBAccount 'Microsoft.DocumentDB/databaseAccounts@2024-12-01-preview' existing = if (!empty(cosmosDBName)) {
  name: cosmosDBName
  scope: resourceGroup(cosmosDBSubscriptionId, cosmosDBResourceGroupName)
}
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' existing = if (!empty(azureStorageName)) {
  name: azureStorageName
  scope: resourceGroup(azureStorageSubscriptionId, azureStorageResourceGroupName)
}

#disable-next-line BCP081
resource foundry_project 'Microsoft.CognitiveServices/accounts/projects@2025-04-01-preview' = {
  parent: foundry
  name: project_name
  tags: tags
  location: location
  identity: !empty(managedIdentityId)
    ? {
        type: 'UserAssigned'
        userAssignedIdentities: {
          '${managedIdentityId}': {}
        }
      }
    : {
        type: 'SystemAssigned'
      }
  properties: {
    description: project_description
    displayName: display_name
  }
}

resource byoAoaiConnectionFoundry 'Microsoft.CognitiveServices/accounts/connections@2025-04-01-preview' = if (!empty(existingAiResourceId) && usingFoundryAiConnection) {
  name: byoAiFoundryConnectionName
  parent: foundry
  properties: {
    category: existingAiKind
    target: existingAiResource!.properties.endpoint
    authType: 'AAD'
    metadata: {
      ApiType: 'Azure'
      ResourceId: existingAiResource.id
      location: existingAiResource!.location
    }
  }
}

resource byoAoaiConnection 'Microsoft.CognitiveServices/accounts/projects/connections@2025-04-01-preview' = if (!empty(existingAiResourceId) && !usingFoundryAiConnection) {
  name: byoAiProjectConnectionName
  parent: foundry_project
  properties: {
    category: existingAiKind
    target: existingAiResource!.properties.endpoint
    authType: 'AAD'
    metadata: {
      ApiType: 'Azure'
      ResourceId: existingAiResource.id
      location: existingAiResource!.location
    }
  }
}

// Account-level CapabilityHost removed to prevent 409 Conflict on deployment retry
// Account-level CapabilityHost is optional - project-level CapabilityHost (created in add-project-capability-host.bicep)
// has higher priority and provides all necessary configuration
// Reference: https://learn.microsoft.com/en-us/azure/ai-foundry/agents/concepts/capability-hosts
//
// Issue: CapabilityHost resources are NOT idempotent by design. If Azure retries the deployment
// for any reason, it attempts to recreate the CapabilityHost, which fails with 409 Conflict.
// Solution: Only create project-level CapabilityHost, which is sufficient for all scenarios.

resource project_connection_cosmosdb_account 'Microsoft.CognitiveServices/accounts/projects/connections@2025-04-01-preview' = if (!empty(cosmosDBName)) {
  name: '${cosmosDBName}-for-${project_name}'
  parent: foundry_project
  properties: {
    category: 'CosmosDB'
    target: cosmosDBAccount!.properties.documentEndpoint
    authType: 'AAD'
    metadata: {
      ApiType: 'Azure'
      ResourceId: cosmosDBAccount.id
      location: cosmosDBAccount!.location
    }
  }
}

resource project_connection_azure_storage 'Microsoft.CognitiveServices/accounts/projects/connections@2025-04-01-preview' = if (!empty(azureStorageName)) {
  name: '${azureStorageName}-for-${project_name}'
  parent: foundry_project
  properties: {
    category: 'AzureStorageAccount'
    target: storageAccount!.properties.primaryEndpoints.blob
    authType: 'AAD'
    metadata: {
      ApiType: 'Azure'
      ResourceId: storageAccount.id
      location: storageAccount!.location
    }
  }
}

resource project_connection_azureai_search 'Microsoft.CognitiveServices/accounts/projects/connections@2025-04-01-preview' = if (!empty(aiSearchName)) {
  name: '${aiSearchName}-for-${project_name}'
  parent: foundry_project
  properties: {
    category: 'CognitiveSearch'
    target: 'https://${aiSearchName}.search.windows.net'
    authType: 'AAD'
    metadata: {
      ApiType: 'Azure'
      ResourceId: searchService.id
      location: searchService!.location
    }
  }
}

// Project-level Bing connection for web research (moved from account level)
// client.connections.list() only returns project-level connections
// FIXED: Connection name uses resourceToken to match Azure's auto-generated format
// Azure rejects 'binggrounding-for-${project_name}' and auto-generates 'binggrounding${resourceToken}'
//
// WORKAROUND: Using 'CustomKeys' category instead of 'BingLLMSearch'
// Reason: BingLLMSearch has a known bug where connections created via Bicep aren't properly
// registered in the project's connection index, causing "connection not found" errors
// See: https://github.com/Azure/azure-sdk-for-python/issues/41768
// Microsoft's recommended workaround uses CustomKeys with Bing API endpoint
resource project_connection_bing 'Microsoft.CognitiveServices/accounts/projects/connections@2025-04-01-preview' = if (!empty(bingAccountId)) {
  name: 'binggrounding${resourceToken}'
  parent: foundry_project
  properties: {
    category: 'CustomKeys'
    target: 'https://api.bing.microsoft.com/'
    authType: 'ApiKey'
    credentials: {
      key: !empty(bingAccountId) ? listKeys(bingAccountId, '2025-05-01-preview').key1 : ''
    }
    metadata: {
      ApiType: 'Azure'
      ResourceId: bingAccountId
      location: 'global'
      Type: 'BingGrounding'
    }
  }
}

output project_name string = foundry_project.name
output project_id string = foundry_project.id
output projectConnectionString string = 'https://${foundry_name}.services.ai.azure.com/api/projects/${project_name}'
output isAiResourceValid bool = isAiResourceValid

// return the BYO connection names
output cosmosDBConnection string = !empty(cosmosDBName) ? project_connection_cosmosdb_account.name : ''
output capabilityHostName string = '' // Account-level CapabilityHost no longer created (see comment above)
output azureStorageConnection string = !empty(azureStorageName) ? project_connection_azure_storage.name : ''
output aiSearchConnection string = !empty(aiSearchName) ? project_connection_azureai_search.name : ''
output aiFoundryConnectionName string = empty(existingAiResourceId)
  ? ''
  : usingFoundryAiConnection ? byoAiFoundryConnectionName : byoAiProjectConnectionName

#disable-next-line BCP053
output projectWorkspaceId string = foundry_project.properties.internalId

output accountPrincipalId string = empty(managedIdentityId)
  ? foundry_project.identity.principalId
  : identity!.properties.principalId

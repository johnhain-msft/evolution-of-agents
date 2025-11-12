
import * as types from '../types/types.bicep'

param aiDependencies types.aiDependenciesType
param existingAiResourceId string?
@allowed([
  'AzureOpenAI'
  'AIServices'
])
param existingAiResourceKind string = 'AIServices'
param location string
param foundryName string
param managedIdentityId string? // Use System Assigned Identity

param projectId int

param bingAccountId string = ''
param bingAccountEndpoint string = ''
param resourceToken string

resource foundry 'Microsoft.CognitiveServices/accounts@2025-04-01-preview' existing = {
  name: foundryName
}

module aiProject './ai-project.bicep' = {
  name: 'ai-project-${projectId}'
  params: {
    foundry_name: foundryName
    location: location
    project_name: 'ai-project-${projectId}'
    project_description: 'AI Project ${projectId}'
    display_name: 'AI Project ${projectId}'
    managedIdentityId: managedIdentityId // Use System Assigned Identity
    existingAiResourceId: existingAiResourceId
    existingAiKind: existingAiResourceKind
    createHubCapabilityHost: false // Account-level CapabilityHost removed - project-level is sufficient

    aiSearchName: aiDependencies.aiSearch.name
    aiSearchServiceResourceGroupName: aiDependencies.aiSearch.resourceGroupName
    aiSearchServiceSubscriptionId: aiDependencies.aiSearch.subscriptionId

    azureStorageName: aiDependencies.azureStorage.name
    azureStorageResourceGroupName: aiDependencies.azureStorage.resourceGroupName
    azureStorageSubscriptionId: aiDependencies.azureStorage.subscriptionId

    cosmosDBName: aiDependencies.cosmosDB.name
    cosmosDBResourceGroupName: aiDependencies.cosmosDB.resourceGroupName
    cosmosDBSubscriptionId: aiDependencies.cosmosDB.subscriptionId

    bingAccountId: bingAccountId
    bingAccountEndpoint: bingAccountEndpoint
    resourceToken: resourceToken
  }
}


module formatProjectWorkspaceId '../ai/format-project-workspace-id.bicep' = {
  name: 'format-project-${projectId}-workspace-id-deployment'
  params: {
    projectWorkspaceId: aiProject.outputs.projectWorkspaceId
  }
}

//Assigns the project SMI the storage blob data contributor role on the storage account

module storageAccountRoleAssignment '../iam/azure-storage-account-role-assignment.bicep' = {
  name: 'storage-role-assignment-deployment-${projectId}'
  scope: resourceGroup(aiDependencies.azureStorage.subscriptionId, aiDependencies.azureStorage.resourceGroupName)
  params: {
    azureStorageName: aiDependencies.azureStorage.name
    projectPrincipalId: aiProject.outputs.accountPrincipalId
  }
}

// The Comos DB Operator role must be assigned before the caphost is created
module cosmosAccountRoleAssignments '../iam/cosmosdb-account-role-assignment.bicep' = {
  name: 'cosmos-account-ra-project-deployment-${projectId}'
  scope: resourceGroup(aiDependencies.cosmosDB.subscriptionId, aiDependencies.cosmosDB.resourceGroupName)
  params: {
    cosmosDBName: aiDependencies.cosmosDB.name
    projectPrincipalId: aiProject.outputs.accountPrincipalId
  }
}

// This role can be assigned before or after the caphost is created
module aiSearchRoleAssignments '../iam/ai-search-role-assignments.bicep' = {
  name: 'ai-search-ra-project-deployment-${projectId}'
  scope: resourceGroup(aiDependencies.aiSearch.subscriptionId, aiDependencies.aiSearch.resourceGroupName)
  params: {
    aiSearchName: aiDependencies.aiSearch.name
    projectPrincipalId: aiProject.outputs.accountPrincipalId
  }
}

// This module creates the project-level capability host
// Account-level CapabilityHost removed to prevent 409 Conflict - project-level is sufficient
module addProjectCapabilityHost 'add-project-capability-host.bicep' = {
  name: 'capabilityHost-configuration-deployment-${projectId}'
  params: {
    accountName: foundryName
    projectName: aiProject.outputs.project_name
    cosmosDBConnection: aiProject.outputs.cosmosDBConnection
    azureStorageConnection: aiProject.outputs.azureStorageConnection
    aiSearchConnection: aiProject.outputs.aiSearchConnection
    aiFoundryConnectionName: aiProject.outputs.aiFoundryConnectionName
  }
  dependsOn: [
     aiProject
     cosmosAccountRoleAssignments
     storageAccountRoleAssignment
     aiSearchRoleAssignments
  ]
}

// The Storage Blob Data Owner role must be assigned after the caphost is created
module storageContainersRoleAssignment '../iam/blob-storage-container-role-assignments.bicep' = {
  name: 'storage-containers-deployment-${projectId}'
  scope: resourceGroup(aiDependencies.azureStorage.subscriptionId, aiDependencies.azureStorage.resourceGroupName)
  params: {
    aiProjectPrincipalId: aiProject.outputs.accountPrincipalId
    storageName: aiDependencies.azureStorage.name
    workspaceId: formatProjectWorkspaceId.outputs.projectWorkspaceIdGuid
  }
  dependsOn: [
    addProjectCapabilityHost
  ]
}

// The Cosmos Built-In Data Contributor role must be assigned after the caphost is created
module cosmosContainerRoleAssignments '../iam/cosmos-container-role-assignments.bicep' = {
  name: 'cosmos-ra-deployment-${projectId}'
  scope: resourceGroup(aiDependencies.cosmosDB.subscriptionId, aiDependencies.cosmosDB.resourceGroupName)
  params: {
    cosmosAccountName: aiDependencies.cosmosDB.name
    projectWorkspaceId: formatProjectWorkspaceId.outputs.projectWorkspaceIdGuid
    projectPrincipalId: aiProject.outputs.accountPrincipalId

  }
dependsOn: [
  addProjectCapabilityHost
  storageContainersRoleAssignment
  ]
}

output capabilityHostUrl string = 'https://portal.azure.com/#/resource/${aiProject.outputs.project_id}/capabilityHosts/${addProjectCapabilityHost.outputs.capabilityHostName}/overview'
output aiConnectionUrl string = 'https://portal.azure.com/#/resource/${foundry.id}/connections/${aiProject.outputs.aiFoundryConnectionName}/overview'
output foundry_connection_string string = aiProject.outputs.projectConnectionString
output projectName string = aiProject.outputs.project_name

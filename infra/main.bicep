// This bicep files deploys one resource group with the following resources:
// 1. The AI Foundry dependencies, such as VNet and
//    private endpoints for AI Search, Azure Storage and Cosmos DB
// 2. The AI Foundry itself
// 3. Two AI Projects with the capability hosts - in Foundry Standard mode
targetScope = 'resourceGroup'

param location string = resourceGroup().location
param myIpAddress string = ''
// Playwright is only available in limited regions: eastus, westus3, westeurope, eastasia
// Default to eastasia (closest to Japan regions)
param playwrightLocation string = 'eastasia'

var resourceToken = toLower(uniqueString(resourceGroup().id, location))
var vnetAddressSpace = '192.168.0.0/16' // Must match vnet.bicep default

module identity 'br/public:avm/res/managed-identity/user-assigned-identity:0.4.0' = {
  name: 'mgmtidentity-${uniqueString(deployment().name, location)}'
  params: {
    name: 'app-identity-${resourceToken}'
    location: location
  }
}

// vnet doesn't have to be in the same RG as the AI Services
// each foundry needs it's own delegated subnet, projects inside of one Foundry share the subnet for the Agents Service
module vnet './modules/networking/vnet.bicep' = {
  name: 'vnet'
  params: {
    vnetName: 'project-vnet-${resourceToken}'
    location: location
  }
}

module ai_dependencies './modules/ai/ai-dependencies-with-dns.bicep' = {
  name: 'ai-dependencies-with-dns'
  params: {
    peSubnetName: vnet.outputs.peSubnetName
    vnetResourceId: vnet.outputs.virtualNetworkId
    resourceToken: resourceToken
    aiServicesName: '' // create AI serviced PE later
    aiAccountNameResourceGroupName: ''
    // Use default existingDnsZones (types.DefaultDNSZones = all null)
    // This creates DNS zones in the current resource group on fresh deployments
    // For hub-spoke: pass existingDnsZones with hub RG name to reference pre-existing zones
  }
}

// --------------------------------------------------------------------------------------------------------------
// -- Log Analytics Workspace and App Insights ------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------------------
module logAnalytics './modules/monitor/loganalytics.bicep' = {
  name: 'log-analytics'
  params: {
    newLogAnalyticsName: 'log-analytics'
    newApplicationInsightsName: 'app-insights'
    location: location
  }
}

// Bing Grounding Resource for web search
resource bingAccount 'Microsoft.Bing/accounts@2025-05-01-preview' = {
  name: 'bing-grounding-${resourceToken}'
  location: 'global'
  kind: 'Bing.Grounding'
  sku: {
    name: 'G1'
  }
  properties: {}
}

// Playwright Workspaces for browser automation (Microsoft.LoadTestService)
// Note: Available regions: eastus, westus3, eastasia, westeurope
// Microsoft.AzurePlaywrightService is deprecated (retires 2026-03-08)
resource playwrightWorkspace 'Microsoft.LoadTestService/playwrightWorkspaces@2025-09-01' = {
  name: 'pw-${resourceToken}'
  location: playwrightLocation
  properties: {
    regionalAffinity: 'Enabled'
    localAuth: 'Enabled'
  }
}

// Role assignment for AI Foundry to access Playwright workspace
// ⚠️  WARNING: FOR DEMO/DEVELOPMENT PURPOSES ONLY
// This assigns the Contributor role, which grants full management access to the Playwright workspace.
// Production environments should follow least privilege principle by using a custom role with only:
//   - Microsoft.LoadTestService/PlaywrightWorkspaces/write
resource playwrightRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(subscription().subscriptionId, resourceGroup().id, playwrightWorkspace.name, 'Contributor')
  scope: playwrightWorkspace
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c') // Contributor role
    principalId: identity.outputs.principalId
    principalType: 'ServicePrincipal'
  }
}

module foundry './modules/ai/ai-foundry.bicep' = {
  name: 'foundry-deployment'
  params: {
    managedIdentityId: '' // Use System Assigned Identity
    name: 'ai-foundry-${resourceToken}'
    location: location
    appInsightsName: logAnalytics.outputs.applicationInsightsName
    publicNetworkAccess: 'Enabled'
    agentSubnetId: vnet.outputs.agentSubnetId // Use the first agent subnet
    logicAppsSubnetId: vnet.outputs.logicAppsSubnetId // Allow Logic Apps to create agents
    myIpAddress: myIpAddress
    playwrightWorkspaceId: playwrightWorkspace.id
    playwrightWorkspaceName: playwrightWorkspace.name
    playwrightLocation: playwrightLocation
    deployments: [
      {
        name: 'gpt-4o'
        properties: {
          model: {
            format: 'OpenAI'
            name: 'gpt-4o'
            version: '2024-11-20'
          }
        }
        sku: {
          name: 'GlobalStandard'
          capacity: 20
        }
      }
      {
        name: 'gpt-4.1'
        properties: {
          model: {
            format: 'OpenAI'
            name: 'gpt-4.1'
            version: '2025-04-14'
          }
        }
        sku: {
          name: 'GlobalStandard'
          capacity: 150
        }
      }
      {
        name: 'gpt-5-mini'
        properties: {
          model: {
            format: 'OpenAI'
            name: 'gpt-5-mini'
            version: '2025-08-07'
          }
        }
        sku: {
          name: 'GlobalStandard'
          capacity: 20
        }
      }
    ]
  }
}

module project1 './modules/ai/ai-project-with-caphost.bicep' = {
  name: 'ai-project-1-with-caphost-${resourceToken}'
  params: {
    foundryName: foundry.outputs.name
    location: location
    projectId: 1
    aiDependencies: ai_dependencies.outputs.aiDependencies
    managedIdentityId: identity.outputs.resourceId
    bingAccountId: bingAccount.id
    bingAccountEndpoint: bingAccount.properties.endpoint
    resourceToken: resourceToken
  }
}

// Grant Logic App managed identity access to AI Foundry project
// Required for Agent action in workflows (AutonomousAgent) to create agents
module logicAppAiFoundryRoleAssignment './modules/iam/role-assignment-foundryProject.bicep' = {
  name: 'logic-app-ai-foundry-role-assignment'
  params: {
    accountName: foundry.outputs.name
    projectName: project1.outputs.projectName
    projectPrincipalId: logicAppsDeployment.outputs.logicAppSystemAssignedPrincipalId
    roleName: 'Azure AI Project Manager'
    servicePrincipalType: 'ServicePrincipal'
  }
  dependsOn: [
    project1
    logicAppsDeployment
  ]
}

// Office 365 connection for Logic Apps
// Uses user-assigned managed identity for access policy (Logic App has both system and user-assigned)
// Agent connections require system-assigned, but Office365 connection works with user-assigned
// Connection name: office365v2 (V2 kind to support connectionRuntimeUrl)
module office365Connection './modules/function/office365-connection.bicep' = {
  name: 'office365-connection'
  params: {
    location: location
    connectionName: 'office365v2'
    logicAppPrincipalId: identity.outputs.principalId
  }
}

module logicAppsDeployment './modules/function/function-app-with-plan.bicep' = {
  name: 'logic-apps-deployment'
  params: {
    name: 'logic-apps-${resourceToken}'
    resourceToken: resourceToken
    managedIdentityId: identity.outputs.resourceId
    location: location
    logAnalyticsWorkspaceResourceId: logAnalytics.outputs.logAnalyticsWorkspaceId
    applicationInsightResourceId: logAnalytics.outputs.applicationInsightsId
    virtualNetworkResourceId: vnet.outputs.virtualNetworkId
    vnetAddressSpace: vnetAddressSpace
    logicAppsSubnetResourceId: vnet.outputs.logicAppsSubnetId
    privateEndpointSubnetResourceId: vnet.outputs.peSubnetId
    logicAppPrivateDnsZoneId: dnsSites.outputs.resourceId
    myIpAddress: myIpAddress
    office365ConnectionRuntimeUrl: office365Connection.outputs.connectionRuntimeUrl
    aiProjectEndpoint: project1.outputs.foundry_connection_string
    aiFoundryName: foundry.outputs.name
    aiProjectName: project1.outputs.projectName
    existingDnsZones: ai_dependencies.outputs.DNSZones
    tags: {
      Environment: 'Production'
      Project: 'EvolutionOfAgents'
      'azd-service-name': 'workflows'
    }
  }
}

module dnsSites 'br/public:avm/res/network/private-dns-zone:0.7.1' = {
  name: 'dns-sites'
  params: {
    name: 'privatelink.azurewebsites.net'
    virtualNetworkLinks: [
      {
        virtualNetworkResourceId: vnet.outputs.virtualNetworkId
      }
    ]
  }
}

output AZURE_OPENAI_CHAT_DEPLOYMENT_NAME string = 'gpt-4.1'
output AZURE_AI_FOUNDRY_CONNECTION_STRING string = project1.outputs.foundry_connection_string
output AZURE_AI_FOUNDRY_SUBSCRIPTION_ID string = foundry.outputs.subscriptionId
output AZURE_AI_FOUNDRY_RESOURCE_GROUP string = foundry.outputs.resourceGroupName
output AZURE_AI_FOUNDRY_NAME string = foundry.outputs.name
output AZURE_AI_FOUNDRY_PROJECT_NAME string = project1.outputs.projectName
output AZURE_TENANT_ID string = tenant().tenantId


// # Logic app standard with workflows for Office 365
output LOGIC_APP_SUBSCRIPTION_ID string = logicAppsDeployment.outputs.subscriptionId
output LOGIC_APP_RESOURCE_GROUP string = logicAppsDeployment.outputs.logicAppResourceGroupName
output LOGIC_APP_NAME string = logicAppsDeployment.outputs.logicAppName

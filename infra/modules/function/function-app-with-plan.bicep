// Deploys a Function App with its own App Service Plan and Storage Account
// Public access is disabled. No VNET integration. Uses zip deployment for source code.
import * as types from '../types/types.bicep'

param name string
param location string
param managedIdentityId string
param resourceToken string
param logAnalyticsWorkspaceResourceId string
param applicationInsightResourceId string
param logicAppsSubnetResourceId string
param privateEndpointSubnetResourceId string
param logicAppPrivateDnsZoneId string
param virtualNetworkResourceId string
param vnetAddressSpace string = '192.168.0.0/16'
param myIpAddress string = ''
param office365ConnectionRuntimeUrl string = ''
param aiProjectEndpoint string = ''
param aiFoundryName string = ''
param aiProjectName string = ''
param tags object = {}

@description('Existing DNS zones to reuse instead of creating new ones')
param existingDnsZones types.DnsZonesType = types.DefaultDNSZones

// --------------------------------------------------------------------------------------------------------------
// split managed identity resource ID to get the name
var identityParts = split(managedIdentityId, '/')
// get the name of the managed identity
var managedIdentityName = length(identityParts) > 0 ? identityParts[length(identityParts) - 1] : ''

resource identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-07-31-preview' existing = {
  name: managedIdentityName
}

// Storage Account for the Function App
module storageAccount 'br/public:avm/res/storage/storage-account:0.25.1' = {
  name: 'storageAccount'
  params: {
    name: take('funstor${resourceToken}', 24)
    location: location
    skuName: 'Standard_LRS'
    kind: 'StorageV2'
    publicNetworkAccess: 'Disabled'
    networkAcls: {
      bypass: 'AzureServices, Logging, Metrics'
      defaultAction: 'Deny'
    }
    roleAssignments: [
      {
        principalId: identity.properties.principalId
        principalType: 'ServicePrincipal'
        roleDefinitionIdOrName: 'Storage Blob Data Owner'
      }
      {
        principalId: identity.properties.principalId
        principalType: 'ServicePrincipal'
        roleDefinitionIdOrName: 'Storage Blob Data Contributor'
      }
      {
        principalId: identity.properties.principalId
        principalType: 'ServicePrincipal'
        roleDefinitionIdOrName: 'Storage Queue Data Contributor'
      }
      {
        principalId: identity.properties.principalId
        principalType: 'ServicePrincipal'
        roleDefinitionIdOrName: 'Storage Table Data Contributor'
      }
    ]

    supportsHttpsTrafficOnly: true
    diagnosticSettings: [
      {
        workspaceResourceId: logAnalyticsWorkspaceResourceId
      }
    ]
    blobServices: {
      diagnosticSettings: [
        {
          workspaceResourceId: logAnalyticsWorkspaceResourceId
        }
      ]
    }
    queueServices: {
      diagnosticSettings: [
        {
          workspaceResourceId: logAnalyticsWorkspaceResourceId
        }
      ]
      queues: [
        {
          name: 'azure-function-weather-input'
          metadata: {
            purpose: 'Function App queue'
          }
        }
        {
          name: 'azure-function-weather-output'
          metadata: {
            purpose: 'Function App queue'
          }
        }
      ]
    }
    privateEndpoints: [
      {
        subnetResourceId: privateEndpointSubnetResourceId
        service: 'blob'
        privateDnsZoneGroup: {
          privateDnsZoneGroupConfigs: [
            {
              privateDnsZoneResourceId: blobDnsZoneId
            }
          ]
        }
      }
      {
        subnetResourceId: privateEndpointSubnetResourceId
        service: 'queue'
        privateDnsZoneGroup: {
          privateDnsZoneGroupConfigs: [
            {
              privateDnsZoneResourceId: queuePrivateDns.outputs.resourceId
            }
          ]
        }
      }
      {
        subnetResourceId: privateEndpointSubnetResourceId
        service: 'table'
        privateDnsZoneGroup: {
          privateDnsZoneGroupConfigs: [
            {
              privateDnsZoneResourceId: tablePrivateDns.outputs.resourceId
            }
          ]
        }
      }
      {
        subnetResourceId: privateEndpointSubnetResourceId
        service: 'file'
        privateDnsZoneGroup: {
          privateDnsZoneGroupConfigs: [
            {
              privateDnsZoneResourceId: filePrivateDns.outputs.resourceId
            }
          ]
        }
      }
    ]
  }
}

// Storage DNS zones - check if blob zone already exists (created by ai_dependencies module)
var blobDnsZoneName = 'privatelink.blob.${environment().suffixes.storage}'
var queueDnsZoneName = 'privatelink.queue.${environment().suffixes.storage}'
var tableDnsZoneName = 'privatelink.table.${environment().suffixes.storage}'
var fileDnsZoneName = 'privatelink.file.${environment().suffixes.storage}'

var blobDnsZone = existingDnsZones[?blobDnsZoneName]

// Reference existing blob DNS zone if it exists
resource blobPrivateDnsZoneExisting 'Microsoft.Network/privateDnsZones@2020-06-01' existing = if (!empty(blobDnsZone)) {
  name: blobDnsZoneName
  scope: resourceGroup(blobDnsZone!.subscriptionId, blobDnsZone!.resourceGroupName)
}

// Create blob DNS zone only if it doesn't already exist
module blobPrivateDnsZoneNew 'br/public:avm/res/network/private-dns-zone:0.7.1' = if (empty(blobDnsZone)) {
  name: 'privateDnsZoneDeployment-blob'
  params: {
    name: blobDnsZoneName
    location: 'global'
    virtualNetworkLinks: [
      { virtualNetworkResourceId: virtualNetworkResourceId }
    ]
  }
}

var blobDnsZoneId = empty(blobDnsZone) ? blobPrivateDnsZoneNew.outputs.resourceId : blobPrivateDnsZoneExisting.id

// Create queue, table, file DNS zones (unique to Logic App storage)
module queuePrivateDns 'br/public:avm/res/network/private-dns-zone:0.7.1' = {
  name: 'privateDnsZoneDeployment-queue'
  params: {
    name: queueDnsZoneName
    location: 'global'
    virtualNetworkLinks: [
      { virtualNetworkResourceId: virtualNetworkResourceId }
    ]
  }
}

module tablePrivateDns 'br/public:avm/res/network/private-dns-zone:0.7.1' = {
  name: 'privateDnsZoneDeployment-table'
  params: {
    name: tableDnsZoneName
    location: 'global'
    virtualNetworkLinks: [
      { virtualNetworkResourceId: virtualNetworkResourceId }
    ]
  }
}

module filePrivateDns 'br/public:avm/res/network/private-dns-zone:0.7.1' = {
  name: 'privateDnsZoneDeployment-file'
  params: {
    name: fileDnsZoneName
    location: 'global'
    virtualNetworkLinks: [
      { virtualNetworkResourceId: virtualNetworkResourceId }
    ]
  }
}

// module serverfarm 'br/public:avm/res/web/serverfarm:0.4.1' = {
//   name: 'serverfarmDeployment'
//   params: {
//     name: 'asp-${resourceToken}'
//     kind: 'elastic'
//     skuName: 'WS1'
//     skuCapacity: 1
//     zoneRedundant: false
//     maximumElasticWorkerCount: 1
//   }
// }

resource serverfarmForLogicApps 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: 'logic-apps-plan-${resourceToken}'
  location: location
  sku: {
    name: 'WS1'
  }
  kind: 'elastic'
}

module logicApp 'br/public:avm/res/web/site:0.19.4' = {
  name: 'logicAppDeployment'
  params: {
    tags: tags
    location: location
    kind: 'functionapp,workflowapp'
    name: '${name}-${resourceToken}'
    serverFarmResourceId: serverfarmForLogicApps.id
    managedIdentities: {
      systemAssigned: true
      userAssignedResourceIds: [managedIdentityId]
    }
    publicNetworkAccess: 'Enabled'

    virtualNetworkSubnetResourceId: logicAppsSubnetResourceId
    outboundVnetRouting: {
      allTraffic: true
      contentShareTraffic: true
    }
    diagnosticSettings: [
      {
        workspaceResourceId: logAnalyticsWorkspaceResourceId
      }
    ]
    httpsOnly: true
    configs: union(
      [
        {
          name: 'appsettings'
          properties: {
            FUNCTIONS_EXTENSION_VERSION: '~4'
            FUNCTIONS_WORKER_RUNTIME: 'dotnet'
            APP_KIND: 'workflowApp'
            // https://review.learn.microsoft.com/en-us/azure/logic-apps/create-single-tenant-workflows-azure-portal?branch=main&branchFallbackFrom=pr-en-us-279972#set-up-managed-identity-access-to-your-storage-account
            // AZURE_CLIENT_ID removed - when not set, defaults to system-assigned identity (required for agent connections)
            // Storage explicitly uses user-assigned via AzureWebJobsStorage__clientId and __managedIdentityResourceId
            AzureWebJobsStorage__credential: 'managedIdentity'
            AzureWebJobsStorage__credentialType: 'managedIdentity'
            AzureWebJobsStorage__managedIdentityResourceId: managedIdentityId
            AzureWebJobsStorage__clientId: identity.properties.clientId
            AzureWebJobsStorage__accountName: storageAccount.outputs.name
            AzureWebJobsSecretStorageType: 'files'
            WEBSITE_NODE_DEFAULT_VERSION: '~22'
            AzureFunctionsJobHost__extensionBundle__id: 'Microsoft.Azure.Functions.ExtensionBundle.Workflows'
            AzureFunctionsJobHost__extensionBundle__version: '[1.*, 2.0.0)'
            WORKFLOWS_SUBSCRIPTION_ID: subscription().subscriptionId
            WORKFLOWS_RESOURCE_GROUP_NAME: resourceGroup().name
            WORKFLOWS_LOCATION_NAME: location
            OFFICE365_CONNECTION_RUNTIME_URL: office365ConnectionRuntimeUrl
            AI_PROJECT_ENDPOINT: aiProjectEndpoint
            AI_FOUNDRY_NAME: aiFoundryName
            AI_PROJECT_NAME: aiProjectName
            AZURE_CLIENT_ID: '' // Empty string explicitly specifies system-assigned identity for agent connections
          }
          storageAccountResourceId: storageAccount.outputs.resourceId
          storageAccountUseIdentityAuthentication: true
          applicationInsightResourceId: applicationInsightResourceId
        }
      ],
      empty(myIpAddress)
        ? []
        : [
            {
              name: 'web'
              properties: {
                ipSecurityRestrictions: [
                  {
                    action: 'Allow'
                    description: 'Allow My IP Address'
                    ipAddress: '${myIpAddress}/32'
                    name: 'My IP Address'
                    priority: 100
                  }
                  {
                    action: 'Allow'
                    description: 'Allow VNet traffic (AI Foundry agents in same VNet)'
                    ipAddress: vnetAddressSpace
                    name: 'VNet Traffic'
                    priority: 200
                  }
                  {
                    action: 'Allow'
                    description: 'Allow Logic Apps Management (runtime operations)'
                    tag: 'ServiceTag'
                    ipAddress: 'LogicAppsManagement'
                    name: 'LogicAppsManagement'
                    priority: 300
                  }
                  {
                    action: 'Allow'
                    description: 'Allow Azure Connectors (Office 365 callbacks)'
                    tag: 'ServiceTag'
                    ipAddress: 'AzureConnectors'
                    name: 'AzureConnectors'
                    priority: 400
                  }
                ]
                ipSecurityRestrictionsDefaultAction: 'Deny'
                scmIpSecurityRestrictionsDefaultAction: 'Deny'
                // scmIpSecurityRestrictionsUseMain: true
                scmIpSecurityRestrictions: empty(myIpAddress)
                  ? []
                  : [
                      {
                        action: 'Allow'
                        description: 'Allow My IP Address'
                        ipAddress: '${myIpAddress}/32'
                        name: 'My IP Address'
                        priority: 100
                      }
                    ]
              }
            }
          ]
    )
    privateEndpoints: !empty(privateEndpointSubnetResourceId)
      ? [
          {
            tags: {}
            subnetResourceId: privateEndpointSubnetResourceId
            service: 'sites'
            privateDnsZoneGroup: {
              privateDnsZoneGroupConfigs: [
                {
                  privateDnsZoneResourceId: logicAppPrivateDnsZoneId
                }
              ]
            }
          }
        ]
      : []
  }
}

output storageAccountName string = storageAccount.outputs.name
output planName string = serverfarmForLogicApps.name
output dnsBlobZoneId string = blobDnsZoneId
output logicAppName string = logicApp.outputs.name
output logicAppResourceId string = logicApp.outputs.resourceId
output logicAppSystemAssignedPrincipalId string = logicApp.outputs.systemAssignedMIPrincipalId
output subscriptionId string = subscription().subscriptionId
output logicAppResourceGroupName string = logicApp.outputs.resourceGroupName

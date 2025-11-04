// Deploys a Function App with its own App Service Plan and Storage Account
// Public access is disabled. No VNET integration. Uses zip deployment for source code.
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
param myIpAddress string = ''
param tags object = {}

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
              privateDnsZoneResourceId: storagePrivateDns[0].outputs.resourceId
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
              privateDnsZoneResourceId: storagePrivateDns[1].outputs.resourceId
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
              privateDnsZoneResourceId: storagePrivateDns[2].outputs.resourceId
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
              privateDnsZoneResourceId: storagePrivateDns[3].outputs.resourceId
            }
          ]
        }
      }
    ]
  }
}

var storageZones = [
  {
    name: 'privatelink.blob.${environment().suffixes.storage}'
  }
  {
    name: 'privatelink.queue.${environment().suffixes.storage}'
  }
  {
    name: 'privatelink.table.${environment().suffixes.storage}'
  }
  {
    name: 'privatelink.file.${environment().suffixes.storage}'
  }
]

module storagePrivateDns 'br/public:avm/res/network/private-dns-zone:0.7.1' = [
  for zone in storageZones: {
    name: 'privateDnsZoneDeployment-${zone.name}'
    params: {
      // Required parameters
      name: zone.name
      // Non-required parameters
      location: 'global'
      virtualNetworkLinks: [
        { virtualNetworkResourceId: virtualNetworkResourceId }
      ]
    }
  }
]

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
    managedIdentities: { userAssignedResourceIds: [managedIdentityId] }
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
            AZURE_CLIENT_ID: identity.properties.clientId
            AzureWebJobsStorage__credential: 'managedIdentity'
            AzureWebJobsStorage__credentialType: 'managedIdentity'
            AzureWebJobsStorage__managedIdentityResourceId: managedIdentityId
            AzureWebJobsStorage__clientId: identity.properties.clientId
            AzureWebJobsStorage__accountName: storageAccount.outputs.name
            AzureWebJobsSecretStorageType: 'files'
            WEBSITE_NODE_DEFAULT_VERSION: '~22'
            AzureFunctionsJobHost__extensionBundle__id: 'Microsoft.Azure.Functions.ExtensionBundle.Workflows'
            AzureFunctionsJobHost__extensionBundle__version: '[1.*, 2.0.0)'
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
output dnsBlobZoneId string = storagePrivateDns[0].outputs.resourceId
output logicAppName string = logicApp.outputs.name
output logicAppResourceId string = logicApp.outputs.resourceId
output subscriptionId string = subscription().subscriptionId
output logicAppResourceGroupName string = logicApp.outputs.resourceGroupName

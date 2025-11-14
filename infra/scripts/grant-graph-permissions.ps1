# Post-deployment script to grant Microsoft Graph API permissions to Logic App
# Grants Calendars.Read and Calendars.ReadWrite permissions to system-assigned managed identity
#
# Prerequisites:
# - Azure CLI logged in with permissions to grant API permissions
# - Logic App deployed with system-assigned managed identity

Write-Host "Granting Microsoft Graph API permissions to Logic App..." -ForegroundColor Cyan

# Get Logic App details from environment
$resourceGroup = if ($env:LOGIC_APP_RESOURCE_GROUP) { $env:LOGIC_APP_RESOURCE_GROUP } else { azd env get-value LOGIC_APP_RESOURCE_GROUP }
$logicAppName = if ($env:LOGIC_APP_NAME) { $env:LOGIC_APP_NAME } else { azd env get-value LOGIC_APP_NAME }

if ([string]::IsNullOrEmpty($logicAppName) -or [string]::IsNullOrEmpty($resourceGroup)) {
    Write-Error "Logic App name or resource group not found in environment"
    exit 1
}

Write-Host "Logic App: $logicAppName in $resourceGroup" -ForegroundColor Green

# Get Logic App's system-assigned managed identity principal ID
$principalId = az functionapp identity show `
    --name $logicAppName `
    --resource-group $resourceGroup `
    --query principalId `
    --output tsv

if ([string]::IsNullOrEmpty($principalId)) {
    Write-Error "Failed to get Logic App managed identity principal ID"
    exit 1
}

Write-Host "Logic App Principal ID: $principalId" -ForegroundColor Green

# Microsoft Graph Service Principal ID (well-known)
$graphAppId = "00000003-0000-0000-c000-000000000000"

# Graph API Permission IDs
$calendarsReadId = "798ee544-9d2d-430c-a058-570e29e34338"      # Calendars.Read
$calendarsReadWriteId = "ef54d2bf-783f-4e0f-bca1-3210c0444d99" # Calendars.ReadWrite

Write-Host "Granting Calendars.Read and Calendars.ReadWrite permissions..." -ForegroundColor Cyan

# Get Graph service principal object ID
$graphSpId = az ad sp list --filter "appId eq '$graphAppId'" --query "[0].id" --output tsv

if ([string]::IsNullOrEmpty($graphSpId)) {
    Write-Error "Failed to get Microsoft Graph service principal ID"
    exit 1
}

# Grant Calendars.Read permission
try {
    $bodyRead = (@{
        principalId = $principalId
        resourceId = $graphSpId
        appRoleId = $calendarsReadId
    } | ConvertTo-Json -Compress).Replace('"', '\"')

    az rest --method POST `
        --uri "https://graph.microsoft.com/v1.0/servicePrincipals/$graphSpId/appRoleAssignedTo" `
        --body $bodyRead `
        --headers "Content-Type=application/json" | Out-Null
    Write-Host "✓ Granted Calendars.Read permission" -ForegroundColor Green
} catch {
    Write-Warning "Calendars.Read permission may already be assigned or failed to grant: $_"
}

# Grant Calendars.ReadWrite permission
try {
    $bodyReadWrite = (@{
        principalId = $principalId
        resourceId = $graphSpId
        appRoleId = $calendarsReadWriteId
    } | ConvertTo-Json -Compress).Replace('"', '\"')

    az rest --method POST `
        --uri "https://graph.microsoft.com/v1.0/servicePrincipals/$graphSpId/appRoleAssignedTo" `
        --body $bodyReadWrite `
        --headers "Content-Type=application/json" | Out-Null
    Write-Host "✓ Granted Calendars.ReadWrite permission" -ForegroundColor Green
} catch {
    Write-Warning "Calendars.ReadWrite permission may already be assigned or failed to grant: $_"
}

Write-Host "Graph API permissions granted successfully!" -ForegroundColor Green
Write-Host "Note: It may take a few minutes for permissions to propagate." -ForegroundColor Yellow

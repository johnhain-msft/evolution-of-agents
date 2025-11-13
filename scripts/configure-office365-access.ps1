# Configure Office 365 Connection Access Policy for Logic App System-Assigned Identity
# Run this script AFTER:
# 1. Infrastructure deployment (azd up)
# 2. Manual OAuth authorization in Azure Portal

Write-Host "Configuring Office 365 connection access policy..." -ForegroundColor Cyan

# Get resource names from azd environment
$RESOURCE_GROUP = azd env get-value AZURE_RESOURCE_GROUP
$LOGIC_APP_NAME = azd env get-value LOGIC_APP_NAME
$SUBSCRIPTION_ID = azd env get-value AZURE_SUBSCRIPTION_ID
$CONNECTION_NAME = "office365v2"

# Get Logic App's system-assigned managed identity principal ID
Write-Host "Getting Logic App system-assigned identity..." -ForegroundColor Yellow
$SYSTEM_IDENTITY_ID = az logicapp show `
  --name "$LOGIC_APP_NAME" `
  --resource-group "$RESOURCE_GROUP" `
  --query "identity.principalId" `
  --output tsv

if ([string]::IsNullOrEmpty($SYSTEM_IDENTITY_ID)) {
  Write-Host "ERROR: Could not get system-assigned identity for Logic App $LOGIC_APP_NAME" -ForegroundColor Red
  exit 1
}

Write-Host "System-assigned identity: $SYSTEM_IDENTITY_ID" -ForegroundColor Green

# Get tenant ID
$TENANT_ID = az account show --query tenantId --output tsv

# Get connection resource ID
$CONNECTION_ID = "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Web/connections/$CONNECTION_NAME"

# Create access policy for system-assigned identity
Write-Host "Adding system-assigned identity to Office 365 connection access policy..." -ForegroundColor Yellow

# Generate policy name using MD5 hash
$md5 = [System.Security.Cryptography.MD5]::Create()
$hashBytes = $md5.ComputeHash([System.Text.Encoding]::UTF8.GetBytes("$CONNECTION_ID$SYSTEM_IDENTITY_ID"))
$POLICY_NAME = [System.BitConverter]::ToString($hashBytes).Replace("-", "").ToLower()

$bodyJson = @{
  properties = @{
    principal = @{
      type = "ActiveDirectory"
      identity = @{
        tenantId = $TENANT_ID
        objectId = $SYSTEM_IDENTITY_ID
      }
    }
  }
} | ConvertTo-Json -Depth 10 -Compress

$tempFile = [System.IO.Path]::GetTempFileName()
[System.IO.File]::WriteAllText($tempFile, $bodyJson, [System.Text.UTF8Encoding]::new($false))

$apiUrl = "https://management.azure.com$CONNECTION_ID/accessPolicies/$POLICY_NAME" + "?api-version=2016-06-01"

az rest --method put `
  --url $apiUrl `
  --headers "Content-Type=application/json" `
  --body "@$tempFile"

# Clean up temp file
Remove-Item $tempFile -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "[SUCCESS] Successfully configured Office 365 connection access policy" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Test your Logic App workflows" -ForegroundColor White
Write-Host "  2. Email actions should now work without permission errors" -ForegroundColor White

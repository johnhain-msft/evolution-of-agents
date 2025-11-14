#!/bin/bash
set -e

# Configure Office 365 Connection Access Policy for Logic App System-Assigned Identity
# Run this script AFTER:
# 1. Infrastructure deployment (azd up)
# 2. Manual OAuth authorization in Azure Portal

echo "Configuring Office 365 connection access policy..."

# Get resource names from azd environment
RESOURCE_GROUP=$(azd env get-value AZURE_RESOURCE_GROUP)
LOGIC_APP_NAME=$(azd env get-value LOGIC_APP_NAME)
SUBSCRIPTION_ID=$(azd env get-value AZURE_SUBSCRIPTION_ID)
CONNECTION_NAME="office365v2"

# Get Logic App's system-assigned managed identity principal ID
echo "Getting Logic App system-assigned identity..."
SYSTEM_IDENTITY_ID=$(az logicapp show \
  --name "$LOGIC_APP_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --query "identity.principalId" \
  --output tsv)

if [ -z "$SYSTEM_IDENTITY_ID" ]; then
  echo "ERROR: Could not get system-assigned identity for Logic App $LOGIC_APP_NAME"
  exit 1
fi

echo "System-assigned identity: $SYSTEM_IDENTITY_ID"

# Get tenant ID
TENANT_ID=$(az account show --query tenantId --output tsv)

# Get connection resource ID
CONNECTION_ID="/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Web/connections/$CONNECTION_NAME"

# Create access policy for system-assigned identity
echo "Adding system-assigned identity to Office 365 connection access policy..."

POLICY_NAME=$(echo -n "$CONNECTION_ID$SYSTEM_IDENTITY_ID" | md5sum | cut -d' ' -f1)

az rest --method put \
  --url "https://management.azure.com${CONNECTION_ID}/accessPolicies/${POLICY_NAME}?api-version=2016-06-01" \
  --headers "Content-Type=application/json" \
  --body "{
    \"properties\": {
      \"principal\": {
        \"type\": \"ActiveDirectory\",
        \"identity\": {
          \"tenantId\": \"$TENANT_ID\",
          \"objectId\": \"$SYSTEM_IDENTITY_ID\"
        }
      }
    }
  }"

echo "✓ Successfully configured Office 365 connection access policy"
echo ""
echo "Next steps:"
echo "1. Test your Logic App workflows"
echo "2. Email actions should now work without permission errors"

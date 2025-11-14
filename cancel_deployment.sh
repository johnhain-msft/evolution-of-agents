#!/bin/bash
# Cancel the stuck cosmos deployment

SUBSCRIPTION_ID="863ad466-5b36-4178-8052-9ed75db2256a"
RG_NAME="rg-jh-pr-test-1"
DEPLOYMENT_NAME="cosmos-ra-deployment-1"

echo "Canceling stuck deployment: $DEPLOYMENT_NAME"
echo "Subscription: $SUBSCRIPTION_ID"
echo "Resource Group: $RG_NAME"
echo ""
echo "Run this command in PowerShell or Azure Cloud Shell:"
echo ""
echo "az deployment group cancel --subscription $SUBSCRIPTION_ID --resource-group $RG_NAME --name $DEPLOYMENT_NAME"

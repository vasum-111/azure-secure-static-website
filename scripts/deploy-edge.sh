#!/usr/bin/env bash
set -euo pipefail
[[ "${AZURE_COST_APPROVED:-}" == "yes" ]] || { echo 'Stop: set AZURE_COST_APPROVED=yes only after approving the resource plan and Azure charges.' >&2; exit 2; }
: "${AZURE_SUBSCRIPTION_ID:?Set the approved Azure subscription ID}"
: "${RESOURCE_GROUP:?Set a dedicated portfolio resource group}"
LOCATION="${LOCATION:-eastus}"
az account set --subscription "$AZURE_SUBSCRIPTION_ID"

: "${STORAGE_ACCOUNT:?Set the storage name from the foundation deployment}"
STORAGE_ID=$(az storage account show -g "$RESOURCE_GROUP" -n "$STORAGE_ACCOUNT" --query id -o tsv)
ORIGIN=$(az storage account show -g "$RESOURCE_GROUP" -n "$STORAGE_ACCOUNT" --query primaryEndpoints.web -o tsv)
ORIGIN=${ORIGIN#https://}; ORIGIN=${ORIGIN%/}
az deployment group create -g "$RESOURCE_GROUP" -n edge -f infra/edge.bicep -p prefix=static originHost="$ORIGIN" privateLinkId="$STORAGE_ID" groupId=web staticSite=true >/dev/null
echo 'Review and approve the pending Front Door private endpoint connection on this storage account. Then verify the site and direct-origin denial.'
az deployment group show -g "$RESOURCE_GROUP" -n edge --query properties.outputs.url.value -o tsv

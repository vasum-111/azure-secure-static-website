#!/usr/bin/env bash
set -euo pipefail
[[ "${AZURE_COST_APPROVED:-}" == "yes" ]] || { echo 'Stop: set AZURE_COST_APPROVED=yes only after approving the resource plan and Azure charges.' >&2; exit 2; }
: "${AZURE_SUBSCRIPTION_ID:?Set the approved Azure subscription ID}"
: "${RESOURCE_GROUP:?Set a dedicated portfolio resource group}"
LOCATION="${LOCATION:-eastus}"
az account set --subscription "$AZURE_SUBSCRIPTION_ID"

az group create -n "$RESOURCE_GROUP" -l "$LOCATION" --tags project=azure-secure-static-website environment=portfolio >/dev/null
az deployment group create -g "$RESOURCE_GROUP" -n foundation -f infra/main.bicep >/dev/null
STORAGE=$(az deployment group show -g "$RESOURCE_GROUP" -n foundation --query properties.outputs.storageName.value -o tsv)
STORAGE_ID=$(az deployment group show -g "$RESOURCE_GROUP" -n foundation --query properties.outputs.storageId.value -o tsv)
echo "Storage created: $STORAGE. Assign Storage Blob Data Contributor to the uploader, then run scripts/upload.sh and scripts/deploy-edge.sh. See DEPLOYMENT.md."

#!/usr/bin/env bash
set -euo pipefail
[[ "${AZURE_COST_APPROVED:-}" == yes ]] || { echo 'Approve the resource plan before uploading.' >&2; exit 2; }
: "${RESOURCE_GROUP:?Set the dedicated resource group}"
: "${STORAGE_ACCOUNT:?Set the storage account}"
: "${UPLOAD_IPV4:?Set the public IPv4 address of this upload machine}"
: "${AZURE_SUBSCRIPTION_ID:?Set the approved subscription}"
[[ "$UPLOAD_IPV4" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]] || exit 2
az account set --subscription "$AZURE_SUBSCRIPTION_ID"
# Allow only this uploader temporarily, and close the public path even on failure.
cleanup() { az storage account update -g "$RESOURCE_GROUP" -n "$STORAGE_ACCOUNT" --public-network-access Disabled >/dev/null; az storage account network-rule remove -g "$RESOURCE_GROUP" --account-name "$STORAGE_ACCOUNT" --ip-address "$UPLOAD_IPV4" >/dev/null; }
trap cleanup EXIT
az storage account update -g "$RESOURCE_GROUP" -n "$STORAGE_ACCOUNT" --default-action Deny --bypass None >/dev/null
az storage account network-rule add -g "$RESOURCE_GROUP" --account-name "$STORAGE_ACCOUNT" --ip-address "$UPLOAD_IPV4" >/dev/null
az storage account update -g "$RESOURCE_GROUP" -n "$STORAGE_ACCOUNT" --public-network-access Enabled >/dev/null
for attempt in {1..12}; do
  if az storage blob service-properties update --account-name "$STORAGE_ACCOUNT" --static-website --index-document index.html --404-document 404.html --auth-mode login >/dev/null; then break; fi
  [[ "$attempt" != 12 ]] || exit 1
  sleep 10
done
az storage blob upload-batch --account-name "$STORAGE_ACCOUNT" --auth-mode login --destination '$web' --source web --overwrite --content-cache-control 'public, max-age=300' >/dev/null
echo 'Content uploaded. Public storage access will now be disabled.'

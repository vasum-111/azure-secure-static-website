# Deploy the secure static website

## Authorization and prerequisites

No Azure resources were created while preparing this repository. Before running a deployment, approve the **subscription, region, resource group, service SKUs, expected runtime and spending limit**. Use a dedicated resource group per project and review the Azure pricing calculator. Budgets notify; they do not automatically cap spending.

Use an authenticated Bash environment with Azure CLI, Bicep, Node.js 24, npm and (for AKS) Docker, kubectl, kubelogin and envsubst. Azure Cloud Shell can run infrastructure commands, but does not provide a local Docker daemon for the release script; run releases on a Docker-capable workstation or GitHub Actions after setup. These templates target Azure public cloud. The initial operator needs resource creation permission plus permission to assign the scoped roles in Bicep. AKS requires an existing Entra administrator group and sufficient VM quota.

~~~bash
az login
export AZURE_SUBSCRIPTION_ID='<approved-subscription-id>'
export RESOURCE_GROUP='<dedicated-project-resource-group>'
export LOCATION=eastus
# Set this only after reviewing/approving the resource plan and charges.
export AZURE_COST_APPROVED=yes
az account set --subscription "$AZURE_SUBSCRIPTION_ID"
~~~

Register the resource providers required by this project if your subscription does not already have them registered. This is an administrator setup action. Read the actual what-if before creating resources.


## Resource plan

StorageV2 / Standard LRS, Front Door **Premium**, a WAF policy with managed rules and rate limiting, and a Front Door-managed Private Link connection. Premium has a meaningful fixed monthly charge even with little traffic. There is no automatic teardown.

## 1. Review and create the storage foundation

~~~bash
az group create -n "$RESOURCE_GROUP" -l "$LOCATION"
az deployment group what-if -g "$RESOURCE_GROUP" -f infra/main.bicep
bash scripts/deploy.sh
export STORAGE_ACCOUNT=$(az deployment group show -g "$RESOURCE_GROUP" -n foundation --query properties.outputs.storageName.value -o tsv)
~~~

Assign the uploader **Storage Blob Data Contributor** scoped to this storage account. The upload operation also needs permission to manage that account's network settings. Prefer an existing authorized operator. Role assignments may need several minutes to propagate. This repository does not create an uploader credential.

## 2. Upload over a narrowly allowed public path

~~~bash
export UPLOAD_IPV4='<public-ipv4-of-this-workstation>'
bash scripts/upload.sh
~~~

The script temporarily permits that single IPv4, enables static website hosting, uploads the original web assets to $web, and disables public access in its exit handler. Run from a workstation outside the storage region's Azure network: storage IP rules do not cover same-region Azure service traffic using private IPs. For a persistent private runner, provision a Blob private endpoint and use a VNet-connected runner instead. This upload procedure is for the dedicated portfolio storage account only.

## 3. Create the edge

The edge script reads the real static website hostname from Azure (including its assigned zone) and creates the Front Door/WAF resources.

~~~bash
bash scripts/deploy-edge.sh
~~~

In Storage → Networking → Private endpoint connections, inspect the new request and approve **only** the Front Door request created for this project. Wait for propagation; private origin approval is separate from successful Bicep deployment.

## 4. Verify and update

1. Visit the Front Door URL printed by the script; it should serve the site over HTTPS.
2. Visit the storage static website hostname directly from the public internet; it must be denied.
3. Confirm the WAF security policy is associated with the endpoint and in Prevention mode.
4. Check Cache-Control and Front Door response headers. Upload changes with upload.sh; allow up to the five-minute content TTL or purge the relevant Front Door paths.

## GitHub Pages preview

Repository Settings → Pages → Deploy from a branch → main → /docs. Pages serves the same static content without Azure. The page explicitly identifies its unverified Azure deployment status.

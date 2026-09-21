# Operations, tradeoffs and interview notes

## Explain the design

Front Door handles global delivery and WAF inspection. Private Link prevents direct public bypass of that inspection. Premium is selected because the private-origin feature is required, even though it costs more than a simple static host.

## Observe and troubleshoot

- Inspect Front Door origin health and WAF metrics in Azure Monitor.
- 502/503 commonly indicates an unapproved private endpoint, a wrong origin hostname, or propagation delay.
- Upload 403 commonly indicates a missing data-plane role, incorrect uploader IP, or a firewall rule still propagating.

Log Analytics export, diagnostic retention and alert rules are **not provisioned**. Enable them after deciding a retention period and budget. Suggested signals: Front Door 5xx/origin health, WAF blocks, AKS unavailable replicas/restarts, SQL connectivity and Redis errors. Avoid logging secrets or full checkout bodies.

## Rollback

Re-upload the previous known-good web directory and purge or wait for the content TTL. Keep infrastructure changes separate from content changes.

## Production gaps

No custom domain, custom certificate, diagnostics export or multi-region storage failover is included. The deployment workflow still needs an approved uploader/network path.

## Cost control and cleanup

Use a dedicated resource group with project/environment tags and create a Cost Management budget before deployment. Review costs daily while learning. Stop or remove unused labs; a stopped app does not stop Front Door, registry, storage or database charges.

After exporting anything you want to keep, inspect the exact resource group:

~~~bash
az resource list --resource-group "$RESOURCE_GROUP" --output table
# Destructive: run only when you intend to remove this entire dedicated lab.
az group delete --name "$RESOURCE_GROUP"
~~~

Check that AKS-managed node resources are removed and inspect remaining resources in the subscription. Retain billing records and verify no orphaned resources remain. Removing a GitHub repository does not remove Azure resources.

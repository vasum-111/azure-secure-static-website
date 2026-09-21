# Validation record

## Checked locally

- Node.js 24 test suite: site structure and explicit preview status.
- Every Bicep file compiled with Microsoft Bicep CLI 0.47.16.
- Dependency lockfile generated; no credentials are included.

## Continuous checks

The Validate workflow runs tests, compiles Bicep and checks shell syntax. Consult the workflow badge for the actual latest GitHub result.

## Still requires an approved Azure environment

- ARM deployment validation/what-if against real subscription policies and quotas.
- Actual resource provisioning and role propagation.
- Private endpoint approval, DNS resolution and application connectivity.
- Storage upload, direct-origin denial and Front Door caching/WAF behavior.
- End-to-end cloud smoke tests, billing review and teardown.

No Azure live endpoint, latency benchmark, availability result or cost saving is claimed without deployment evidence.

# Secure Static Website with CDN

[![Validate](https://github.com/vasum-111/azure-secure-static-website/actions/workflows/ci.yml/badge.svg)](https://github.com/vasum-111/azure-secure-static-website/actions/workflows/ci.yml)
![License: MIT](https://img.shields.io/badge/license-MIT-green)

A small static site with a real edge-security design: global delivery, a WAF and a private Blob Storage origin.

**[Open browser preview](https://vasum-111.github.io/azure-secure-static-website/)** · **[Deployment guide](DEPLOYMENT.md)** · **[Operations & tradeoffs](OPERATIONS.md)**

> **Deployment status:** the public browser preview is static hosting on GitHub Pages. It displays the website content. Azure resources have **not** been provisioned; cloud deployment awaits subscription access and cost approval. Bicep compilation and local tests are validation, not evidence of a successful Azure deployment.

## What this demonstrates

- Original responsive portfolio site and custom 404 page.
- Front Door Premium with managed WAF rules, rate limiting and HTTPS redirect.
- Private Link to the static website origin; public storage access disabled after upload.
- Two-stage Bicep deployment and an IP-restricted content upload script.

## Architecture

~~~mermaid
flowchart LR
    Visitor -->|HTTPS| Edge[Front Door Premium + WAF]
    Edge -->|Private Link / HTTPS| Blob[Blob Storage static website]
    Developer -->|IP-restricted upload / Entra ID| Blob
    GitHub[GitHub Pages] -. Browser preview only .-> Visitor
~~~

Front Door is the only intended public entry. The storage account starts closed, opens temporarily to one uploader IP, then closes again. Front Door connects through an approved private endpoint.

## Run locally

Prerequisite: Node.js 24 LTS and npm.

~~~bash
git clone https://github.com/vasum-111/azure-secure-static-website.git
cd azure-secure-static-website
npm ci
npm test
npm start
~~~

Open **http://localhost:8080**. No cloud account is needed to view the site locally.


## Repository map

| Path | Purpose |
|---|---|
| web/ | Original website  |
| docs/ | GitHub Pages preview; static content copy |
| infra/ | Bicep resource definitions |
| scripts/ | Explicit deployment helpers |

| test/ | Automated checks |
| .github/workflows/ | Continuous validation  |

## Validation and limitations

See [VALIDATION.md](VALIDATION.md) for tested behavior and unverified cloud steps. This is a learning/portfolio project, not a production certification. 

## Specification and attribution

Built from the three-project scope supplied by the user from the **Azure Services Crash Course**. The original PDF attachment was unavailable in this task, so its exact text and resource links could not be checked. The user-provided project names/services are the scope of record. Application code, layout, artwork and project structure are original; no third-party repository was copied. Microsoft documentation informed service configuration. See [REFERENCES.md](REFERENCES.md). MIT license covers this repository; dependencies retain their own licenses.

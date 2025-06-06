# Let's Encrypt Certificate Automation for Azure Key Vault

This project provides an automated workflow to generate Let's Encrypt SSL certificates for **subdomains**, using **Cloudflare DNS-01 challenge**, and securely **upload them to Azure Key Vault**.

---

## Overview

This repository contains:
- A GitHub Actions workflow (`.github/workflows/letsencrypt-cert.yml`)
- Two shell scripts:
  - `scripts/generate_cert.sh`: Generates an SSL certificate using `acme.sh` and converts it to `.pfx`.
  - `scripts/upload_to_kv.sh`: Uploads the generated `.pfx` certificate to Azure Key Vault.

---

## Features

- Supports **manual trigger** with custom domain input.
- Uses **Cloudflare API** to validate domain ownership via DNS challenge.
- Uses **OIDC-based authentication** with federated credentials to authenticate to Azure.
- Certificate is stored in Azure Key Vault in `.pfx` format.
- Certificate name is automatically derived from the domain (`subdomain.domain.com → subdomain-domain-com`).

---

## Required GitHub Secrets

You must configure the following secrets under **Repository Settings > Secrets and variables > Actions**:

| Name                 | Description                                                                 |
|----------------------|-----------------------------------------------------------------------------|
| `CF_TOKEN`           | Cloudflare API Token with permissions to manage DNS records                |
| `CF_ACCOUNT_ID`      | Cloudflare Account ID (optional for some DNS setups, safe to include)      |
| `AZURE_CLIENT_ID`    | Client ID of your Azure AD App (used for federated auth via OIDC)          |
| `AZURE_CLIENT_SECRET`| Client Secret (not used with OIDC login, but can be left for fallback)     |
| `AZURE_TENANT_ID`    | Azure AD Tenant ID                                                         |
| `AZURE_KEYVAULT_NAME`| Name of the Azure Key Vault where the cert will be stored                  |

## Usage

### Triggering the Workflow

Run the GitHub Actions workflow manually from the UI:

```text
Actions > Generate and Store Let's Encrypt Certificat > Run workflow
```

## Personnal note

Ravi, wake up !
# Automated Let's Encrypt Certificate for Azure Key Vault

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
- Renew them **automatically** on a daily schedule when they reach the renewal window (50–59 days before expiry) while observing the Let’s Encrypt rate‑limit.
- **Parallel renewal** control how many renewals run at once by adjusting strategy.max-parallel in letsencrypt-renew.yml.
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
| `AZURE_CLIENT_ID`    | Client ID of your Azure AD App (used for federated auth via OIDC)          |
| `AZURE_CLIENT_SECRET`| Client Secret (not used with OIDC login, but can be left for fallback)     |
| `AZURE_TENANT_ID`    | Azure AD Tenant ID                                                         |
| `AZURE_KEYVAULT_NAME`| Name of the Azure Key Vault where the cert will be stored                  |

## Usage

### Triggering the Workflow

Run the GitHub Actions workflow manually from the UI:

```text
Actions > Generate and Store Let's Encrypt Certificate > Run workflow
```

### Automatic renewal

letsencrypt-renew.yml is triggered every day. It renews certificates that:

expire in ≤ 59 days and ≥ 50 days;

have not exceeded the 50‑certs/week safeguard Let's Encrypt SSL.

No manual action is needed/just ensure the GitHub secrets remain valid.

### Testing tips

To simulate a near‑expiry certificate, override the thresholds temporarily:

Repo Settings → Variables → add THRESHOLD_MIN=88, THRESHOLD_MAX=92.

Trigger the Daily Let’s Encrypt Renewal workflow manually.

Remove the variables afterwards to revert to production behaviour.

## Personnal note

Ravi, wake up !

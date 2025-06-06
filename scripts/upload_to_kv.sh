#!/bin/bash

set -e

DOMAIN=$1
KV_NAME=$2
CERT_NAME=$3

if [[ -z "$DOMAIN" || -z "$KV_NAME" || -z "$CERT_NAME" ]]; then
  echo "Usage: ./upload_to_kv.sh <domaine> <kv_name> <cert_name>"
  exit 1
fi

az login --service-principal \
  --username "$AZURE_CLIENT_ID" \
  --password "$AZURE_CLIENT_SECRET" \
  --tenant "$AZURE_TENANT_ID"

EXISTING=$(az keyvault certificate show \
  --vault-name "$KV_NAME" \
  --name "$CERT_NAME" \
  --query "attributes.expires" -o tsv 2>/dev/null || true)

if [ -n "$EXISTING" ]; then
  echo "🔎 Certificat déjà présent, expiration : $EXISTING"
  EXP_DATE=$(date -d "$EXISTING" +%s)
  NOW=$(date +%s)
  if (( EXP_DATE > NOW )); then
    echo "Certificat valid, no update."
    exit 0
  else
    echo "Certificat expired, update in progress
  fi
else
  echo "No certificat, create new"
fi

az keyvault certificate import \
  --vault-name "$KV_NAME" \
  --name "$CERT_NAME" \
  --file output/${DOMAIN}.pfx \
  --password ""

#!/bin/bash

set -e

DOMAIN=$1
VAULT_NAME=$2
CERT_NAME=$3

if [ -z "$DOMAIN" ] || [ -z "$VAULT_NAME" ] || [ -z "$CERT_NAME" ]; then
  echo "Usage: $0 <domain> <keyvault_name> <cert_name>"
  exit 1
fi

PFX_PATH="output/${DOMAIN}.pfx"

if [ ! -f "$PFX_PATH" ]; then
  echo "Error: Certificate file $PFX_PATH not found"
  exit 1
fi

echo "Uploading $PFX_PATH to Key Vault $VAULT_NAME with name $CERT_NAME..."

az keyvault certificate import \
  --vault-name "$VAULT_NAME" \
  --name "$CERT_NAME" \
  --file "$PFX_PATH" \
  --password ""

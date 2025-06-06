#!/bin/bash

set -e

DOMAIN=$1

export CF_Token="${CF_TOKEN}"
export CF_Account_ID="${CF_ACCOUNT_ID}"

if [ -z "$DOMAIN" ]; then
  echo "Domain name is required"
  exit 1
fi

# Installer acme.sh si nécessaire
if [ ! -d "$HOME/.acme.sh" ]; then
  curl https://get.acme.sh | sh
  export PATH="$HOME/.acme.sh:$PATH"
else
  export PATH="$HOME/.acme.sh:$PATH"
fi

# Changer de CA vers Let's Encrypt
acme.sh --set-default-ca --server letsencrypt

# Demande du certificat uniquement pour le sous-domaine
acme.sh --issue --dns dns_cf -d "$DOMAIN" --keylength ec-256 --force

# Création du dossier output
mkdir -p output

# Installation du certificat localement
acme.sh --install-cert -d "$DOMAIN" \
  --key-file output/${DOMAIN}.key \
  --fullchain-file output/${DOMAIN}.crt \
  --ecc

# Conversion en PFX
openssl pkcs12 -export \
  -out output/${DOMAIN}.pfx \
  -inkey output/${DOMAIN}.key \
  -in output/${DOMAIN}.crt \
  -passout pass:

#!/bin/bash

set -e

DOMAIN=$1

export CF_Token="${CF_TOKEN}"
export CF_Account_ID="${CF_ACCOUNT_ID}"

if [ -z "$DOMAIN" ]; then
  echo "Domain name is required"
  exit 1
fi

if [ ! -d "$HOME/.acme.sh" ]; then
  curl https://get.acme.sh | sh
  export PATH="$HOME/.acme.sh:$PATH"
fi

acme.sh --set-default-ca --server letsencrypt

acme.sh --issue --dns dns_cf -d "$DOMAIN" -d "*.$DOMAIN" --keylength ec-256 --force

mkdir -p output

acme.sh --install-cert -d "$DOMAIN" \
  --key-file output/${DOMAIN}.key \
  --fullchain-file output/${DOMAIN}.crt \
  --ecc

openssl pkcs12 -export \
  -out output/${DOMAIN}.pfx \
  -inkey output/${DOMAIN}.key \
  -in output/${DOMAIN}.crt \
  -passout pass:

#!/usr/bin/env bash

set -euo pipefail

VAULT_NAME="${1?Key Vault name required}"

THRESHOLD_MIN=88
THRESHOLD_MAX=92
MAX_RENEWALS=50

mapfile -t CERTS < <(
  az keyvault certificate list \
    --vault-name "$VAULT_NAME" \
    --query '[].name' -o tsv
)

renew_json="[]"

echo "WINDOW = ${THRESHOLD_MIN}-${THRESHOLD_MAX}  MAX = ${MAX_RENEWALS}"


for CERT_NAME in "${CERTS[@]}"; do

  EXPIRY=$(az keyvault certificate show --vault-name "$VAULT_NAME" --name "$CERT_NAME" \
           --query 'attributes.expires' -o tsv 2>/dev/null || true)
  DOMAIN=$(az keyvault certificate show --vault-name "$VAULT_NAME" --name "$CERT_NAME" \
           --query 'tags.domain' -o tsv 2>/dev/null || true)

  if [[ -z "$DOMAIN" ]]; then
    DOMAIN="${CERT_NAME//-/\.}"
  fi

  [[ -z "$EXPIRY" ]] && continue

  EXP_SEC=$(date -d "$EXPIRY" +%s)
  NOW_SEC=$(date +%s)
  DAYS_LEFT=$(( (EXP_SEC - NOW_SEC) / 86400 ))

  if (( DAYS_LEFT >= THRESHOLD_MIN && DAYS_LEFT <= THRESHOLD_MAX )); then
    renew_json=$(jq --arg domain "$DOMAIN" '. + [$domain]' <<<"$renew_json")
  fi
done

renew_json=$(jq 'sort' <<<"$renew_json")

COUNT=$(jq 'length' <<<"$renew_json")
if (( COUNT > MAX_RENEWALS )); then
  renew_json=$(jq ".[0:$MAX_RENEWALS]" <<<"$renew_json")
fi

echo "renew_list=$renew_json" >>"$GITHUB_OUTPUT"

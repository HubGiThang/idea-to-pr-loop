#!/usr/bin/env bash
# Sets a repo up to deploy to Cloudflare from GitHub Actions (.github/workflows/deploy.yml). Not needed
# when Cloudflare's own Git build deploys the repo (docs/cloudflare.md): use one route per repo.
#
# For each repo it sets the secret CLOUDFLARE_API_TOKEN and the variables CLOUDFLARE_ACCOUNT_ID and
# CLOUDFLARE_DEPLOY=actions. It asks for the token once, without showing it, and passes it to
# `gh secret set` through stdin, so it never appears in your shell history or on a command line.
#
#   bash setup/set-cloudflare.sh OWNER/REPO [OWNER/REPO ...]
#
# Undo for one repo: gh variable delete CLOUDFLARE_DEPLOY -R OWNER/REPO
set -euo pipefail

if [ $# -eq 0 ]; then
  echo "Usage: bash setup/set-cloudflare.sh OWNER/REPO [OWNER/REPO ...]" >&2
  exit 2
fi

read -rp "Cloudflare account ID: " account
read -rsp "Paste the Cloudflare API token: " token
echo
if [ -z "$account" ] || [ -z "$token" ]; then
  echo "Account ID or token missing, nothing changed." >&2
  exit 1
fi

for repo in "$@"; do
  printf '%s' "$token" | gh secret set CLOUDFLARE_API_TOKEN -R "$repo"
  gh variable set CLOUDFLARE_ACCOUNT_ID -R "$repo" --body "$account"
  gh variable set CLOUDFLARE_DEPLOY -R "$repo" --body actions
  echo "$repo: CLOUDFLARE_API_TOKEN, CLOUDFLARE_ACCOUNT_ID and CLOUDFLARE_DEPLOY=actions set"
done
unset token

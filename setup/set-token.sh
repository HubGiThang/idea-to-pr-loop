#!/usr/bin/env bash
# Step 1: adds your Claude token as the secret CLAUDE_CODE_OAUTH_TOKEN on each repo.
# Get the token first with `claude setup-token`. This script asks for it once, without showing
# it, and passes it to `gh secret set` through stdin, so it never appears in your shell history
# or on a command line.
#
#   bash setup/set-token.sh OWNER/REPO [OWNER/REPO ...]
set -euo pipefail

if [ $# -eq 0 ]; then
  echo "Usage: bash setup/set-token.sh OWNER/REPO [OWNER/REPO ...]" >&2
  exit 2
fi

read -rsp "Paste the token from 'claude setup-token': " token
echo
if [ -z "$token" ]; then
  echo "No token given, nothing changed." >&2
  exit 1
fi

for repo in "$@"; do
  printf '%s' "$token" | gh secret set CLAUDE_CODE_OAUTH_TOKEN -R "$repo"
  echo "$repo: CLAUDE_CODE_OAUTH_TOKEN set"
done
unset token

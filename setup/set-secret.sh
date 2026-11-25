#!/usr/bin/env bash
# Adds any one secret to each repo, for example REFERENCE_REPOS_TOKEN or AUTO_MERGE_TOKEN. It asks
# for the value once, without showing it, and passes it to `gh secret set` through stdin, so it
# never appears in your shell history or on a command line.
#
#   bash setup/set-secret.sh SECRET_NAME OWNER/REPO [OWNER/REPO ...]
set -euo pipefail

if [ $# -lt 2 ]; then
  echo "Usage: bash setup/set-secret.sh SECRET_NAME OWNER/REPO [OWNER/REPO ...]" >&2
  exit 2
fi
name="$1"; shift

read -rsp "Paste the value for $name: " value
echo
if [ -z "$value" ]; then
  echo "No value given, nothing changed." >&2
  exit 1
fi

for repo in "$@"; do
  printf '%s' "$value" | gh secret set "$name" -R "$repo"
  echo "$repo: $name set"
done
unset value

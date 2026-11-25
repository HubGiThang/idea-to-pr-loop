#!/usr/bin/env bash
# Connects a Worker to its GitHub repo with Cloudflare's own Git build (Workers Builds), so every
# push to the default branch deploys to production and every other branch gets a preview. Both run
# ./scripts/deploy.sh. This is the recommended deploy route: GitHub holds no Cloudflare secret.
#
#   CLOUDFLARE_ACCOUNT_ID=<id> bash setup/connect-cloudflare-builds.sh OWNER/REPO WORKER_NAME
#
# Before you run it (docs/cloudflare.md has the steps):
# - The Worker exists (deploy it once) and its name matches `name` in the repo's wrangler config.
# - The Cloudflare GitHub app is installed on the repo (Workers & Pages, any Worker, Settings,
#   Builds, Connect).
# - You have a user API token with Workers Builds Configuration: Edit and Workers Scripts: Read.
#   The script asks for it once, without showing it. Account-owned tokens do not work for this API.
# - A build token exists (the same Connect screen can create one). If the account has several, set
#   BUILD_TOKEN_UUID to the one to use; the script lists them otherwise.
#
# The build token decides what a deploy may touch. Cloudflare's default one covers Workers, KV, R2
# and routes. If the repo uses D1, pick a build token that also has D1: Edit, or migrations fail.
set -euo pipefail

if [ $# -ne 2 ] || [ -z "${CLOUDFLARE_ACCOUNT_ID:-}" ]; then
  echo "Usage: CLOUDFLARE_ACCOUNT_ID=<id> bash setup/connect-cloudflare-builds.sh OWNER/REPO WORKER_NAME" >&2
  exit 2
fi
repo="$1"; worker="$2"
owner="${repo%/*}"; name="${repo#*/}"
api="https://api.cloudflare.com/client/v4/accounts/$CLOUDFLARE_ACCOUNT_ID"

read -rsp "Paste your Cloudflare user API token (Workers Builds Configuration: Edit): " token
echo
[ -n "$token" ] || { echo "No token given, nothing changed." >&2; exit 1; }

# The token goes to curl through stdin, never on the command line.
cf() { printf 'header = "Authorization: Bearer %s"\n' "$token" | curl -sS --config - "$@"; }

tag=$(cf "$api/workers/scripts" | jq -r --arg w "$worker" '.result[]? | select(.id == $w) | .tag')
[ -n "$tag" ] || { echo "No Worker named $worker in this account. Deploy it once first." >&2; exit 1; }

owner_id=$(gh api "users/$owner" --jq .id)
repo_id=$(gh api "repos/$repo" --jq .id)
branch=$(gh api "repos/$repo" --jq .default_branch)

build_token="${BUILD_TOKEN_UUID:-}"
if [ -z "$build_token" ]; then
  tokens=$(cf "$api/builds/tokens" | jq -c '[.result[]? | {build_token_uuid, build_token_name}]')
  if [ "$(jq length <<< "$tokens")" = 1 ]; then
    build_token=$(jq -r '.[0].build_token_uuid' <<< "$tokens")
  else
    echo "Set BUILD_TOKEN_UUID to one of these build tokens and run again:" >&2
    jq -r '.[] | "  \(.build_token_uuid)  \(.build_token_name)"' <<< "$tokens" >&2
    exit 1
  fi
fi

body=$(jq -n --arg tag "$tag" --arg owner_id "$owner_id" --arg owner "$owner" --arg repo_id "$repo_id" \
  --arg name "$name" --arg branch "$branch" --arg bt "$build_token" '{
    script_tag: $tag,
    git_repository: {provider_type: "github", provider_account_id: $owner_id, provider_account_name: $owner,
      repo_id: $repo_id, repo_name: $name, branch: $branch},
    production_settings: {build_command: "", deploy_command: "./scripts/deploy.sh production", build_token_uuid: $bt},
    previews_enabled: true,
    previews_base_config: {build_command: "", deploy_command: "./scripts/deploy.sh preview", build_token_uuid: $bt}
  }')

result=$(cf "$api/builds/workers" --request POST --header "Content-Type: application/json" --data "$body")
unset token
if [ "$(jq -r '.success' <<< "$result")" = true ]; then
  echo "$repo: connected to the Worker $worker. Pushes to $branch deploy; other branches get previews."
else
  echo "$repo: Cloudflare refused the request:" >&2
  jq -r '.errors[]? | "  \(.code): \(.message)"' <<< "$result" >&2
  exit 1
fi

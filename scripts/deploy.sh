#!/usr/bin/env bash
# The one deploy command, whichever way the repo deploys to Cloudflare (docs/cloudflare.md):
# Cloudflare's own Git build, the GitHub Actions deploy workflow, or your computer.
#
#   ./scripts/deploy.sh production   # the main branch: apply D1 migrations, then deploy
#   ./scripts/deploy.sh preview      # any other branch: a preview; production is not touched
#
# Sign-in comes from the environment: CLOUDFLARE_API_TOKEN and CLOUDFLARE_ACCOUNT_ID in CI
# (Cloudflare's build supplies its own token), or `wrangler login` on your computer.
# A repo with nothing to deploy can leave this file as it is: it exits without doing anything.
set -euo pipefail

# ---- Fill these in for your repo -------------------------------------------------------------
APP_DIR="."            # the folder that holds the wrangler config
BUILD_COMMAND=""       # for example "pnpm install --frozen-lockfile && pnpm build"; empty for none
D1_DATABASES=""        # D1 databases to migrate before a production deploy, separated by spaces
PAGES_PROJECT=""       # only for a Pages project: its name. Leave empty for a Worker
PAGES_OUTPUT_DIR="dist"
WRANGLER="${WRANGLER:-npx wrangler}"
# A Worker preview. Use "versions upload" instead if your Wrangler is older than 4.135.
PREVIEW_COMMAND="preview"
# ----------------------------------------------------------------------------------------------

mode="${1:-}"
case "$mode" in
  production|preview) ;;
  *) echo "Usage: ./scripts/deploy.sh production|preview" >&2; exit 2 ;;
esac

cd "$APP_DIR"
if [ -z "$PAGES_PROJECT" ] && ! ls wrangler.jsonc wrangler.json wrangler.toml > /dev/null 2>&1; then
  echo "Nothing to deploy: no wrangler config in $APP_DIR and no PAGES_PROJECT set."
  exit 0
fi

if [ -n "$BUILD_COMMAND" ]; then
  echo "Building: $BUILD_COMMAND"
  bash -c "$BUILD_COMMAND"
fi

branch="${GITHUB_HEAD_REF:-${WORKERS_CI_BRANCH:-$(git rev-parse --abbrev-ref HEAD 2> /dev/null || echo preview)}}"

if [ "$mode" = production ]; then
  # Migrations only add things (CLAUDE.md), so applying them before the new code is safe.
  for db in $D1_DATABASES; do
    echo "Applying D1 migrations: $db"
    $WRANGLER d1 migrations apply "$db" --remote
  done
  if [ -n "$PAGES_PROJECT" ]; then
    $WRANGLER pages deploy "$PAGES_OUTPUT_DIR" --project-name "$PAGES_PROJECT" --branch main
  else
    $WRANGLER deploy
  fi
else
  # Previews never run migrations against the production database.
  if [ -n "$PAGES_PROJECT" ]; then
    $WRANGLER pages deploy "$PAGES_OUTPUT_DIR" --project-name "$PAGES_PROJECT" --branch "$branch"
  else
    $WRANGLER $PREVIEW_COMMAND
  fi
fi

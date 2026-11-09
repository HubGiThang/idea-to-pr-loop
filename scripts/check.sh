#!/usr/bin/env bash
# The one command that says "this change is good". CI runs it, and Claude runs it before
# opening or updating a PR. Claude's workflows may only run this script, so put every
# install, lint, typecheck, build and test step your repo needs in here.
set -euo pipefail

echo "TODO: replace this with your install, lint, typecheck, build and test commands."
# Examples:
#   pnpm install --frozen-lockfile && pnpm lint && pnpm -r typecheck && pnpm test
#   npm ci && npm run lint && npm test
#   pip install -r requirements.txt && ruff check . && pytest
exit 1

#!/usr/bin/env bash
# Step 6, last: lets GitHub merge a PR by itself once its required checks pass. For each repo it
# turns on Settings > General > "Allow auto-merge" and sets the repository variable
# AUTO_MERGE=true, which claude.yml reads.
# A repo without the "protect main" ruleset is skipped: with no required checks, auto-merge would
# merge every PR at once.
#
#   bash setup/turn-on-auto-merge.sh OWNER/REPO [OWNER/REPO ...]
#
# Undo for one repo: gh variable delete AUTO_MERGE -R OWNER/REPO
set -euo pipefail

if [ $# -eq 0 ]; then
  echo "Usage: bash setup/turn-on-auto-merge.sh OWNER/REPO [OWNER/REPO ...]" >&2
  exit 2
fi

for repo in "$@"; do
  if ! gh api "repos/$repo/rulesets" --jq '.[].name' | grep -qx 'protect main'; then
    echo "$repo: no protect main ruleset, skipped (run setup/add-ruleset.sh first)"
    continue
  fi
  gh api -X PATCH "repos/$repo" -F allow_auto_merge=true --jq '"auto-merge allowed: \(.allow_auto_merge)"' \
    | sed "s|^|$repo: |"
  gh variable set AUTO_MERGE -R "$repo" --body true
  echo "$repo: AUTO_MERGE=true"
done

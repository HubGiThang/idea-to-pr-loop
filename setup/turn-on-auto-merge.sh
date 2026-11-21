#!/usr/bin/env bash
# Step 6, last: lets GitHub merge a PR by itself once its required checks pass. For each repo it
# turns on Settings > General > "Allow auto-merge" and sets the repository variable
# AUTO_MERGE=true, which claude.yml reads.
# A repo without an active "protect main" ruleset that requires status checks is skipped: with no required checks, auto-merge would
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
  id=$(gh api "repos/$repo/rulesets" --jq '[.[] | select(.name == "protect main" and .enforcement == "active")][0].id // empty')
  if [ -z "$id" ]; then
    echo "$repo: no active protect main ruleset, skipped (run setup/add-ruleset.sh, or setup/pause-ruleset.sh $repo on)"
    continue
  fi
  required=$(gh api "repos/$repo/rulesets/$id" --jq '[.rules[] | select(.type == "required_status_checks")] | length')
  if [ "$required" -eq 0 ]; then
    echo "$repo: protect main has no required status checks, skipped"
    continue
  fi
  gh api -X PATCH "repos/$repo" -F allow_auto_merge=true --jq '"auto-merge allowed: \(.allow_auto_merge)"' \
    | sed "s|^|$repo: |"
  gh variable set AUTO_MERGE -R "$repo" --body true
  echo "$repo: AUTO_MERGE=true"
done

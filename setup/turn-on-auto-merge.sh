#!/usr/bin/env bash
# Step 6, last: lets GitHub merge a PR by itself once its required checks pass. For each repo it
# turns on Settings > General > "Allow auto-merge" and sets the repository variable
# AUTO_MERGE=true, which claude.yml reads.
# A repo is skipped unless its "protect main" ruleset is active and requires at least one check:
# with no required checks, auto-merge would merge every PR at once. That includes a ruleset paused
# with setup/pause-ruleset.sh.
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
  id=$(gh api "repos/$repo/rulesets" --jq '[.[] | select(.name == "protect main")][0].id // empty')
  if [ -z "$id" ]; then
    echo "$repo: no protect main ruleset, skipped (run setup/add-ruleset.sh first)"
    continue
  fi
  read -r enforcement checks < <(gh api "repos/$repo/rulesets/$id" --jq \
    '"\(.enforcement) \([.rules[] | select(.type == "required_status_checks") | .parameters.required_status_checks[]] | length)"')
  if [ "$enforcement" != active ]; then
    echo "$repo: protect main is $enforcement, skipped (turn it on: bash setup/pause-ruleset.sh $repo on)"
    continue
  fi
  if [ "$checks" -eq 0 ]; then
    echo "$repo: protect main requires no checks, skipped (add check and Merge gate to it first)"
    continue
  fi
  gh api -X PATCH "repos/$repo" -F allow_auto_merge=true --jq '"auto-merge allowed: \(.allow_auto_merge)"' \
    | sed "s|^|$repo: |"
  gh variable set AUTO_MERGE -R "$repo" --body true
  echo "$repo: AUTO_MERGE=true"
done

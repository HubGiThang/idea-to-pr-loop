#!/usr/bin/env bash
# Turns the "protect main" ruleset off or back on, for merging a PR that changes workflow files.
# The Claude action won't run on a PR that changes its own workflow files, so those PRs never get
# a Claude verdict, their Merge gate stays red and they can't merge through the ruleset. Merge them by hand:
#
#   bash setup/pause-ruleset.sh OWNER/REPO off
#   gh pr merge <number> -R OWNER/REPO --merge     # once its CI is green
#   bash setup/pause-ruleset.sh OWNER/REPO on
#
# Turn it back on right away: while it is off, any PR can merge, including ones with needs-human.
set -euo pipefail

if [ $# -ne 2 ] || { [ "$2" != off ] && [ "$2" != on ]; }; then
  echo "Usage: bash setup/pause-ruleset.sh OWNER/REPO off|on" >&2
  exit 2
fi
repo=$1
if [ "$2" = off ]; then enforcement=disabled; else enforcement=active; fi

id=$(gh api "repos/$repo/rulesets" --jq '.[] | select(.name == "protect main") | .id')
if [ -z "$id" ]; then
  echo "$repo: no protect main ruleset" >&2
  exit 1
fi
gh api -X PUT "repos/$repo/rulesets/$id" -f enforcement="$enforcement" --jq '"protect main: \(.enforcement)"' \
  | sed "s|^|$repo: |"

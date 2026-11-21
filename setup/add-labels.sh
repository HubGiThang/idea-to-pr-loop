#!/usr/bin/env bash
# Step 3: creates the labels you add by hand or from Linear: `claude` (build this), `needs-human`
# (a question for the spec's Design review) and `bug-fix` (restores approved behavior, no mockup
# needed). The workflows create their other labels (fix-round-1..3, attempt-2) themselves.
# Safe to run again: an existing label keeps its name and gets these colors and descriptions.
#
#   bash setup/add-labels.sh OWNER/REPO [OWNER/REPO ...]
set -euo pipefail

if [ $# -eq 0 ]; then
  echo "Usage: bash setup/add-labels.sh OWNER/REPO [OWNER/REPO ...]" >&2
  exit 2
fi

for repo in "$@"; do
  gh label create claude -R "$repo" --force --color 7057FF \
    --description "Claude builds this issue"
  gh label create needs-human -R "$repo" --force --color B60205 \
    --description "Waiting on a design decision"
  gh label create bug-fix -R "$repo" --force --color D93F0B \
    --description "Restores approved behavior; no mockup needed"
  echo "$repo: labels claude, needs-human, bug-fix ready"
done

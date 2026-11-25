#!/usr/bin/env bash
# Makes a clean copy of this template to hand to another person or organization: a zip of the
# committed files with no git history, so no author names, commit messages or branch names travel
# with it. It also leaves out the parts that only serve this copy's own public page, replaces the
# address of this copy with a placeholder, and refuses to finish if the personal information check
# finds anything.
#
#   bash setup/export.sh [OUT.zip]
#
# List your own names (yours, your company's, your products', your team keys) in .handoff-denylist
# first, one per line, so the check can look for them (scripts/check-personal-info.sh).
# The receiver unzips it, runs `git init`, and pushes it to a new private repo of their own.
set -euo pipefail

root=$(git rev-parse --show-toplevel)
cd "$root"
out="${1:-$root/idea-to-pr-loop-handoff.zip}"
case "$out" in /*) ;; *) out="$PWD/$out" ;; esac

if [ -n "$(git status --porcelain)" ]; then
  echo "Note: uncommitted changes are not included. The export is the last commit."
fi
owner=$(git remote get-url origin 2> /dev/null | sed -E 's#(\.git)?$##; s#.*[:/]([^/]+)/[^/]+$#\1#' || true)

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
copy="$work/idea-to-pr-loop"
mkdir "$copy"
git archive HEAD | tar -x -C "$copy"

# Parts that only serve this copy's own public page.
rm -f "$copy/.github/workflows/site-dispatch.yml" "$copy/docs/site-markers.md"
find "$copy" -name '*.md' -print0 | while IFS= read -r -d '' f; do
  sed -i.bak -E '/site-dispatch\.yml/d; /^<!-- \/?loop:[a-z-]+ -->$/d' "$f" && rm -f "$f.bak"
done

# This copy's address becomes a placeholder.
if [ -n "$owner" ]; then
  grep -rlIi --null -e "$owner" "$copy" | while IFS= read -r -d '' f; do
    sed -i.bak -E "s#$owner#<ORG>#Ig" "$f" && rm -f "$f.bak"
  done
fi

LOOP_SOURCE_OWNER="$owner" LOOP_DENYLIST="${LOOP_DENYLIST:-$root/.handoff-denylist}" \
  bash "$copy/scripts/check-personal-info.sh" "$copy"

rm -f "$out"
if command -v zip > /dev/null; then
  (cd "$work" && zip -qr "$out" idea-to-pr-loop)
else
  (cd "$work" && python3 -m zipfile -c "$out" idea-to-pr-loop)
fi
echo "Wrote $out ($(find "$copy" -type f | wc -l | tr -d ' ') files, no git history)."
echo "Start at handoff/README.md."

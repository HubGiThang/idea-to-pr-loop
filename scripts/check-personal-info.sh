#!/usr/bin/env bash
# Looks for personal or account information in a folder before it is shared: email addresses,
# links into someone's Notion, Linear or Claude workspace, session links, token-shaped strings,
# long IDs, and the name of the account the files came from. Exits 1 if it finds any.
#
#   bash scripts/check-personal-info.sh [FOLDER]
#
# Names that are personal to you (your own, your company's, your products', your team keys) cannot
# be listed in this file, because the file itself is shared. Put them in a deny list instead: one
# pattern per line (extended regex, matched without regard to case), lines starting with # skipped.
# It is read from $LOOP_DENYLIST, or .handoff-denylist in the folder you run this from, which git
# ignores.
# Set LOOP_SOURCE_OWNER to an account name to flag every mention of it. By default it is the owner
# of this clone's origin remote.
set -euo pipefail

dir="${1:-.}"
denylist="${LOOP_DENYLIST:-.handoff-denylist}"
owner="${LOOP_SOURCE_OWNER:-$(git -C "$dir" remote get-url origin 2> /dev/null | sed -E 's#(\.git)?$##; s#.*[:/]([^/]+)/[^/]+$#\1#' || true)}"

patterns=(
  '[A-Za-z0-9._%+-]+@[A-Za-z0-9-]+(\.[A-Za-z0-9-]+)*\.[A-Za-z]{2,}'   # email addresses
  'notion\.(so|com|site)/[^ )>"]*[0-9a-f]{32}'                         # a Notion page
  'linear\.app/[a-z0-9-]+/'                                            # a Linear workspace
  'claude\.ai/(artifact|code|chat|project|share)/'                     # a Claude page or session
  'chatgpt\.com/(c|share|g)/'                                          # a ChatGPT conversation
  '(ghp|gho|ghu|ghs|ghr)_[A-Za-z0-9]{30,}|github_pat_[A-Za-z0-9_]{30,}' # GitHub tokens
  'sk-[A-Za-z0-9_-]{20,}|xox[abp]-[A-Za-z0-9-]{10,}'                   # API keys
  '\b[0-9a-f]{32}\b|\b[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\b' # account and page IDs
)
[ -n "$owner" ] && patterns+=("$owner")
if [ -f "$denylist" ]; then
  while IFS= read -r line || [ -n "$line" ]; do
    case "$line" in ''|'#'*) continue ;; esac
    patterns+=("$line")
  done < "$denylist"
else
  echo "Note: no deny list at $denylist, so only the general patterns are checked."
fi

found=0
for p in "${patterns[@]}"; do
  if hits=$(grep -rIniE --exclude-dir=.git --exclude=.handoff-denylist -e "$p" "$dir"); then
    # Addresses that are examples or belong to a tool, not a person.
    hits=$(grep -viE 'git@github\.com|noreply@|@(v[0-9]|main\b|\*)|example\.(com|org)' <<< "$hits" || true)
    [ -z "$hits" ] && continue
    found=1
    echo "Found /$p/:"
    cut -c1-200 <<< "$hits" | sed 's/^/  /'
  fi
done

if [ "$found" = 1 ]; then
  echo "Personal or account information found. Replace it with a placeholder in angle brackets." >&2
  exit 1
fi
echo "No personal or account information found in $dir."

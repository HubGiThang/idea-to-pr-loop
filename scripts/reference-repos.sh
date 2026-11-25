#!/usr/bin/env bash
# Copies other repos into .reference/ so Claude can read them while it builds. The copies are
# read-only context: each is a snapshot without its git history, .reference/ is kept out of every
# commit, and nothing is ever pushed back. The repos can live on GitHub, Azure DevOps or any host
# that serves git over https (see docs/reference-repos.md).
#
#   bash scripts/reference-repos.sh [LIST]
#
# LIST defaults to .github/reference-repos.txt: one repo per line, an https clone URL and an
# optional folder name. Blank lines and lines starting with # are skipped.
#
# With REFERENCE_REPOS_TOKEN set (a read-only token), it is sent only for these clones and is not
# stored. Without it, git uses whatever sign-in your computer already has.
# The workflows read this script and the list from the default branch, so a PR cannot change where
# the token is sent.
set -euo pipefail

list="${1:-.github/reference-repos.txt}"
[ -f "$list" ] || { echo "No $list; nothing to fetch."; exit 0; }

auth=()
if [ -n "${REFERENCE_REPOS_TOKEN:-}" ]; then
  basic=$(printf 'pat:%s' "$REFERENCE_REPOS_TOKEN" | base64 | tr -d '\n')
  auth=(-c "http.extraheader=Authorization: Basic $basic")
fi

mkdir -p .reference
if [ -d .git ] && ! grep -qxF '.reference/' .git/info/exclude 2>/dev/null; then
  echo '.reference/' >> .git/info/exclude
fi

count=0
while read -r url name _ || [ -n "${url:-}" ]; do
  case "${url:-}" in ''|'#'*) continue ;; esac
  case "$url" in
    https://*) ;;
    *) echo "::warning::Skipped $url: only https clone URLs are allowed."; continue ;;
  esac
  name="${name:-$(basename "${url%.git}")}"
  if ! [[ "$name" =~ ^[A-Za-z0-9._-]+$ ]] || [ "$name" = . ] || [ "$name" = .. ]; then
    echo "::warning::Skipped $url: the folder name may only have letters, digits, dots, dashes and underscores."
    continue
  fi
  rm -rf ".reference/$name"
  if GIT_TERMINAL_PROMPT=0 git ${auth[@]+"${auth[@]}"} clone --quiet --depth 1 "$url" ".reference/$name"; then
    rm -rf ".reference/$name/.git"
    count=$((count + 1))
    echo "Fetched $name"
  else
    echo "::warning::Could not fetch $name. Check the URL and that the token can read it."
  fi
done < "$list"
echo "$count reference repo(s) in .reference/"

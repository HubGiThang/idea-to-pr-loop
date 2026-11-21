#!/usr/bin/env bash
# Merge gate: posts a "Merge gate" commit status on a PR's head commit. It passes only when
# - the PR has no needs-human label (a design question is waiting on the spec's Design review), and
# - no review thread (from Claude, Codex or a person) is unresolved, and
# - the Claude review of the head commit ended "Verdict: ready to merge" (the review job records that as a
#   "Claude verdict" commit status on the exact commit it reviewed), and
# - the Codex review has finished. Codex reviews when a PR is opened or marked ready, not on every push, so
#   the gate waits until it has finished at least once and is not running now. Its findings arrive as review
#   threads, which the thread check above already holds the gate for.
#
# It runs as the last step of the Claude review and Claude fix jobs (which are running anyway), not as a
# workflow of its own: each workflow job is billed as at least one minute, and the gate takes seconds.
# The workflows read this script from the default branch, so a PR cannot change its own gate.
#
# Needs: GH_TOKEN (with statuses: write), REPO (owner/name), PR (number).
# Optional: NO_REVIEW_LABEL, a label for PRs that skip the Claude review on purpose (for example owner
# requests built by a form). Those PRs skip the verdict and Codex checks; needs-human and threads still apply.
# Optional: CODEX_REVIEW=off for a repo without the ChatGPT Codex app, so the gate doesn't wait for Codex.
set -euo pipefail

owner="${REPO%/*}"; name="${REPO#*/}"
sha=$(gh pr view "$PR" -R "$REPO" --json headRefOid --jq .headRefOid)

post() { # state, description
  gh api "repos/$REPO/statuses/$sha" -f state="$1" -f context="Merge gate" -f description="${2:0:140}" > /dev/null
  if [ "$1" = success ]; then echo "Merge gate passed: $2"; else echo "::error::Merge gate: $2"; fi
}

labels=$(gh pr view "$PR" -R "$REPO" --json labels --jq '[.labels[].name] | join(",")')
if echo ",$labels," | grep -q ",needs-human,"; then
  post failure "A design question is waiting (needs-human). It clears when the spec is approved again."
  exit 0
fi

# Count every unresolved thread, outdated or not: a fix push makes old threads outdated,
# including security threads still waiting for a second check.
unresolved=$(gh api graphql --paginate -F owner="$owner" -F name="$name" -F pr="$PR" -f query='
  query($owner:String!,$name:String!,$pr:Int!,$endCursor:String){
    repository(owner:$owner,name:$name){
      pullRequest(number:$pr){
        reviewThreads(first:100, after:$endCursor){
          nodes{ isResolved }
          pageInfo{ hasNextPage endCursor }
        }
      }
    }
  }' --jq '[.data.repository.pullRequest.reviewThreads.nodes[] | select(.isResolved==false)] | length' \
  | awk '{s+=$1} END {print s+0}')
if [ "$unresolved" -gt 0 ]; then
  post failure "$unresolved review thread(s) unresolved. The fix workflow answers and resolves them."
  exit 0
fi

if [ -n "${NO_REVIEW_LABEL:-}" ] && echo ",$labels," | grep -q ",$NO_REVIEW_LABEL,"; then
  post success "No design question and no unresolved threads (no Claude review on $NO_REVIEW_LABEL PRs)."
  exit 0
fi

# The Claude review of this exact commit must say ready to merge. The review job writes the "Claude verdict"
# status on the commit it reviewed, so a verdict never carries over to a newer commit.
verdict=$(gh api "repos/$REPO/commits/$sha/statuses" --paginate \
  | jq -rs '[add[] | select(.context == "Claude verdict")] | sort_by(.created_at) | last | .state // "none"')
if [ "$verdict" = "none" ]; then
  post failure "No Claude review verdict for the latest commit yet."
  exit 0
fi
if [ "$verdict" != "success" ]; then
  post failure "The latest Claude review says changes are needed."
  exit 0
fi

# Codex must have finished reviewing. Its summary comment carries a machine-readable state; older PRs may only
# have a Codex review or a thumbs-up reaction (Codex's "no findings").
if [ "${CODEX_REVIEW:-}" != off ]; then
  codex=$(gh api "repos/$REPO/issues/$PR/comments" --paginate | jq -rs '
    [add[] | select(.user.login == "chatgpt-codex-connector[bot]") | .body
           | select(contains("codex-review-state:v1"))] | last // ""
    | (capture("codex-review-state:v1 (?<j>[^\n]*?) -->").j // "")
    | gsub("&#123;"; "{") | gsub("&#125;"; "}")
    | (try (fromjson | .code_review.status // "") catch "")')
  case "$codex" in
    running|queued|pending|in_progress)
      post failure "The Codex review is still running."
      exit 0 ;;
    "")
      reviewed=$(gh api "repos/$REPO/pulls/$PR/reviews" --paginate \
        | jq -s '[add[] | select(.user.login == "chatgpt-codex-connector[bot]")] | length')
      thumbs=$(gh api "repos/$REPO/issues/$PR/reactions" --paginate \
        | jq -s '[add[] | select(.user.login == "chatgpt-codex-connector[bot]" and .content == "+1")] | length')
      if [ "$reviewed" -eq 0 ] && [ "$thumbs" -eq 0 ]; then
        post failure "Waiting for the Codex review."
        exit 0
      fi ;;
  esac
fi
post success "No design question, no unresolved threads, Codex has reviewed, and the latest Claude review says ready to merge."

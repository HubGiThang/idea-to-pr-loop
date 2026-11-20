#!/usr/bin/env bash
# Merge gate: posts a "Merge gate" commit status on a PR's head commit. It passes only when
# - the PR has no needs-human label (a design question is waiting on the spec's Design review), and
# - no review thread (from Claude, Codex or a person) is unresolved, and
# - the latest Claude review summary, written after the latest commit, ends "Verdict: ready to merge".
#
# It runs as the last step of the Claude review and Claude fix jobs (which are running anyway), not as a
# workflow of its own: each workflow job is billed as at least one minute, and the gate takes seconds.
# The workflows read this script from the default branch, so a PR cannot change its own gate.
#
# Needs: GH_TOKEN (with statuses: write), REPO (owner/name), PR (number).
# Optional: NO_REVIEW_LABEL, a label for PRs that skip the Claude review on purpose (for example owner
# requests built by a form). Those PRs skip only the verdict check; needs-human and threads still apply.
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

# The latest Claude review summary must be newer than the latest commit and say ready to merge.
head_date=$(gh pr view "$PR" -R "$REPO" --json commits --jq '.commits[-1].committedDate')
verdict=$(gh pr view "$PR" -R "$REPO" --json comments --jq '
  [.comments[] | select((.author.login | test("^claude"; "i")) and (.body | test("Verdict: (ready to merge|changes needed)")))]
  | sort_by(.updatedAt // .createdAt) | last
  | if . == null then "none" else "\(.updatedAt // .createdAt) \(if (.body | test("Verdict: ready to merge")) then "ready" else "changes" end)" end')
if [ "$verdict" = "none" ]; then
  post failure "No Claude review verdict yet."
  exit 0
fi
verdict_date="${verdict% *}"; verdict_word="${verdict##* }"
if [[ "$verdict_date" < "$head_date" ]]; then
  post failure "The latest Claude review is older than the latest commit. Waiting for a new review."
  exit 0
fi
if [ "$verdict_word" != "ready" ]; then
  post failure "The latest Claude review says changes are needed."
  exit 0
fi
post success "No design question, no unresolved threads, and the latest review says ready to merge."

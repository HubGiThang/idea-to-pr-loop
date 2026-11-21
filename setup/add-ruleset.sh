#!/usr/bin/env bash
# Step 5: adds the "protect main" ruleset to each repo: no deleting the default branch, no force
# push, changes only through a pull request (0 approvals), and the required checks.
# Run it after the first PR has run CI and been reviewed, so GitHub has seen the check names.
# Skips a repo that already has a ruleset named "protect main".
#
#   bash setup/add-ruleset.sh OWNER/REPO [OWNER/REPO ...]
#   bash setup/add-ruleset.sh -c "Lint" -c "Unit tests" -c "Merge gate" OWNER/REPO
#
# Without -c it requires `check` (the job in ci.yml) and `Merge gate`. With -c, list every check
# to require, Merge gate included. Use the job names exactly as they show on a PR.
set -euo pipefail

usage() {
  echo "Usage: bash setup/add-ruleset.sh [-c CHECK]... OWNER/REPO [OWNER/REPO ...]" >&2
  exit 2
}

checks=()
while getopts "c:h" opt; do
  case $opt in
    c) checks+=("$OPTARG") ;;
    *) usage ;;
  esac
done
shift $((OPTIND - 1))
[ $# -gt 0 ] || usage
[ ${#checks[@]} -gt 0 ] || checks=("check" "Merge gate")

# 15368 is the GitHub Actions app, which runs CI and posts the Merge gate status.
checks_json=$(printf '%s\n' "${checks[@]}" | jq -R '{context: ., integration_id: 15368}' | jq -s .)

for repo in "$@"; do
  existing=$(gh api "repos/$repo/rulesets" --jq '.[] | select(.name == "protect main") | .enforcement')
  if [ -n "$existing" ]; then
    echo "$repo: already has protect main ($existing), skipped"
    [ "$existing" = active ] || echo "$repo: it is not active, run: bash setup/pause-ruleset.sh $repo on"
    continue
  fi
  jq -n --argjson checks "$checks_json" '{
    name: "protect main", target: "branch", enforcement: "active",
    conditions: {ref_name: {include: ["~DEFAULT_BRANCH"], exclude: []}},
    rules: [
      {type: "deletion"},
      {type: "non_fast_forward"},
      {type: "pull_request", parameters: {required_approving_review_count: 0,
        dismiss_stale_reviews_on_push: false, require_code_owner_review: false,
        require_last_push_approval: false, required_review_thread_resolution: false,
        allowed_merge_methods: ["merge", "squash", "rebase"]}},
      {type: "required_status_checks", parameters: {strict_required_status_checks_policy: false,
        required_status_checks: $checks}}
    ]}' | gh api -X POST "repos/$repo/rulesets" --input - --jq '"protect main added (id \(.id))"' \
    | sed "s|^|$repo: |"
done

# GitHub setup

Do these once per repo.

## Apps and secret

1. **Claude GitHub App:** install it from github.com/apps/claude and give it access to the repo.
2. **Claude token:** on your computer run `claude setup-token`, then add the result as a repository secret named `CLAUDE_CODE_OAUTH_TOKEN` (Settings → Secrets and variables → Actions). The workflows then run on your Claude subscription, not paid API usage.
3. **ChatGPT Codex:** install the ChatGPT Codex Connector GitHub App for the repo, and in Codex settings turn on **Automatic review** (trigger: on PR open). Codex reviews a PR when it opens for review, when a draft is marked ready, or when someone comments `@codex review`.
4. **Linear:** connect the repo in Linear's GitHub integration (see docs/linear.md).

## Files

Copy `.github/workflows/`, `scripts/check.sh` and `CLAUDE.md.template` (renamed to `CLAUDE.md`) into the repo, then fill in `scripts/check.sh` and the CLAUDE.md placeholders. Labels (`fix-round-1..3`, `needs-human`) are created by the workflows the first time they are needed. Create `auto-merge` yourself if you use Auto-merge.

## Protect main

After the first PR has run CI (so the `check` job shows up as a choice), go to Settings → Rules → Rulesets → New branch ruleset:

- Name `protect main`, enforcement Active, target the default branch.
- Restrict deletions.
- Block force pushes.
- Require a pull request before merging (0 approvals is fine for a solo repo).
- Require status checks to pass, and add `check`.
- Leave the bypass list empty.

`Merge gate` does not need to be required here: Claude's merge rule in CLAUDE.md already waits for it, and requiring it would also block people from merging a PR they have decided on.

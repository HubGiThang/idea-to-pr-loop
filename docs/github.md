# GitHub setup

Do these once per repo. The scripts in [setup/](../setup/README.md) do the token, labels, ruleset and auto-merge for one or many repos.

## Apps and secret

1. **Claude GitHub App:** install it from github.com/apps/claude and give it access to the repo.
2. **Claude token:** on your computer run `claude setup-token`, then add the result as a repository secret named `CLAUDE_CODE_OAUTH_TOKEN` (Settings → Secrets and variables → Actions). The workflows then run on your Claude subscription, not paid API usage.
3. **ChatGPT Codex:** install the ChatGPT Codex Connector GitHub App for the repo, and in Codex settings turn on **Automatic review** (trigger: on PR open). Codex reviews a PR when it opens for review, when a draft is marked ready, or when someone comments `@codex review`.
4. **Linear:** connect the repo in Linear's GitHub integration (see docs/linear.md).

## Files

Copy `.github/workflows/`, `.github/actions/`, `.github/reference-repos.txt`, everything in `scripts/` and `CLAUDE.md.template` (renamed to `CLAUDE.md`) into the repo, then fill in `scripts/check.sh`, the settings at the top of `scripts/deploy.sh` and the CLAUDE.md placeholders. The workflows install the repo's languages by themselves ([toolchains](toolchains.md)). The workflows create `fix-round-1..3`, `needs-human` and `attempt-2` the first time they need them. Create `claude`, `needs-human` and `bug-fix` up front with `bash setup/add-labels.sh OWNER/REPO`, so they exist before the first issue (Linear's sync, if you use it, also brings them over).

## Protect main

After the first PR has run CI and been reviewed (so `check` and the `Merge gate` status show up as choices; `scripts/merge-gate.sh` must be on main first), run `bash setup/add-ruleset.sh OWNER/REPO`, or by hand go to Settings → Rules → Rulesets → New branch ruleset:

- Name `protect main`, enforcement Active, target the default branch.
- Restrict deletions.
- Block force pushes.
- Require a pull request before merging (0 approvals is fine for a solo repo).
- Require status checks to pass, and add `check` and `Merge gate`. Leave "Require branches to be up to date" off: with auto-merge it would re-run CI on every open PR each time one merges.
- Leave the bypass list empty.

Then turn on auto-merge ([docs/options.md](options.md#how-prs-merge)) with `bash setup/turn-on-auto-merge.sh OWNER/REPO`, or by hand: Settings → General → **Allow auto-merge**, and the repository variable `AUTO_MERGE` = `true`.

A PR that changes workflow files never gets a Claude verdict, so it can't pass the Merge gate. Merge it by hand with the ruleset briefly off ([setup/README.md](../setup/README.md#prs-that-change-workflow-files)).

`Merge gate` is what keeps a PR from merging on its own while a design question is open (`needs-human`), a review thread is unresolved, or the latest Claude review is missing, stale or says changes are needed. It is a commit status, not a workflow run: the review and fix jobs post it as their last step (`scripts/merge-gate.sh`, read from main so a PR can't change its own gate), and `merge-gate.yml` only runs when you remove `needs-human` or re-run it by hand (`gh workflow run merge-gate.yml -f pr=<number>`). A new push has no status yet, so the gate stays closed until the next review.

## Keeping CI cheap

GitHub bills every job as at least one minute, and private repos share a monthly allowance. The template keeps runs down:

- CI skips draft PRs and doesn't run again on main after a merge (the PR already passed). Deploy workflows still build main.
- The Merge gate is a status posted by jobs that are already running, not its own workflow.
- A newer push cancels the run in progress.

When you fill in `ci.yml` and `scripts/check.sh`:

- The shared toolchain step already turns on each language's cache.
- Cache test browsers, for example Playwright's: `actions/cache` on `~/.cache/ms-playwright`, keyed on the lockfile, and run `playwright install chromium` only on a cache miss.
- Don't install system packages the runner image already has (for example skip `playwright install-deps`).
- Put a job-level `if:` on other workflows that react to common events (labels, comments), so the job is skipped rather than started and stopped. Skipped jobs aren't billed.

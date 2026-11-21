# Options

## Keep Claude attribution out

By default Claude Code may add a `Co-Authored-By` line to commits and a footer to PR descriptions. To turn that off:

1. In each workflow, uncomment the `settings:` line under `anthropics/claude-code-action@v1`.
2. In `CLAUDE.md`, uncomment the attribution rule under Git, so Claude also leaves it out of comments and files.

## How PRs merge

- **Auto-merge (recommended):** set the repository variable `AUTO_MERGE` to `true` (Settings → Secrets and variables → Actions → Variables) and turn on **Allow auto-merge** (Settings → General). `claude.yml` then turns on GitHub auto-merge for each PR it opens, and GitHub merges it once the required checks pass. Make both `check` and `Merge gate` required first ([docs/github.md](github.md#protect-main)): without required checks, GitHub would merge at once.
- **Without Codex:** the `Merge gate` waits for the ChatGPT Codex review to finish. In a repo without the Codex app, set the repository variable `CODEX_REVIEW` to `off` so the gate doesn't wait for a review that never comes.
- **Human merge:** leave `AUTO_MERGE` unset. Claude builds, reviews and fixes; a person merges. Useful for a new repo until you trust its checks.

A merge set up with the built-in `GITHUB_TOKEN` starts no workflows on `main`. If `main` deploys through a workflow, add a fine-grained token with Contents and Pull requests write access as the secret `AUTO_MERGE_TOKEN`; the merge is then made as its owner and the deploy runs.

## Number of fix rounds

`claude-fix.yml` runs at most 3 rounds per attempt, and one second attempt. To change the rounds, edit the `for i in 1 2 3` loop, the `-ge 3` check and the `'3'` comparisons in that file.

# Repo settings

These are the settings only a repo admin can change. The scripts here do them with the GitHub CLI, for one repo or many at once. Every repo with the loop gets the same settings.

You need [`gh`](https://cli.github.com) signed in as an admin of the repos (`gh auth login`) and `jq`. Run the scripts from a clone of this template; they take `OWNER/REPO` arguments and change nothing else. Each one skips or overwrites safely if you run it twice.

Do the steps in this order, once the repo has the workflows on `main`. Turn on auto-merge last: without the ruleset's required checks, it would merge every PR at once.

| Step | What | How |
|---|---|---|
| 1 | Secret `CLAUDE_CODE_OAUTH_TOKEN` | Run `claude setup-token`, then `bash setup/set-token.sh OWNER/REPO ...` (asks for the token once, never shows it) |
| 2 | Apps | By hand: install the [Claude GitHub app](https://github.com/apps/claude) and the ChatGPT Codex Connector on the repo, and turn on Codex's **Automatic review**. No Codex? Set the variable `CODEX_REVIEW=off` ([docs/options.md](../docs/options.md#how-prs-merge)) |
| 3 | Labels `claude`, `needs-human`, `bug-fix` | `bash setup/add-labels.sh OWNER/REPO ...` |
| 4 | Linear | Nothing per repo when one Linear team covers several repos: install the Linear GitHub app on all repositories, leave GitHub Issues sync off, and Claude opens each GitHub issue with a `Linear: ABC-12` line when it cuts a spec. One team per repo can use the sync instead ([docs/linear.md](../docs/linear.md)) |
| 5 | Ruleset "protect main" | After the first PR has run CI and been reviewed: `bash setup/add-ruleset.sh OWNER/REPO ...` (requires `check` and `Merge gate`; pass `-c NAME` for each check if your CI jobs have other names) |
| 6 | Auto-merge | `bash setup/turn-on-auto-merge.sh OWNER/REPO ...` (Allow auto-merge plus the variable `AUTO_MERGE=true`; skips repos without the ruleset) |

Optional: the secret `AUTO_MERGE_TOKEN`, if `main` deploys through a workflow ([docs/options.md](../docs/options.md#how-prs-merge)), and the variable `NO_REVIEW_LABEL` for PRs that skip the Claude review on purpose (see `merge-gate.yml`).

## Example

```sh
claude setup-token
bash setup/set-token.sh   my-org/web my-org/api
bash setup/add-labels.sh  my-org/web my-org/api
# install the apps by hand, merge the first PR, then:
bash setup/add-ruleset.sh my-org/web my-org/api
bash setup/add-ruleset.sh -c "Lint and test" -c "Merge gate" my-org/docs
bash setup/turn-on-auto-merge.sh my-org/web my-org/api my-org/docs
```

## PRs that change workflow files

The Claude action won't run on a PR that changes its own workflow files, so such a PR never gets a Claude verdict and its Merge gate stays red. This includes updating a repo to a newer version of this template. Merge these by hand, once CI is green:

```sh
bash setup/pause-ruleset.sh OWNER/REPO off
gh pr merge <number> -R OWNER/REPO --merge
bash setup/pause-ruleset.sh OWNER/REPO on
```

Turn the ruleset back on right away. While it is off, any PR can merge, including one waiting on a design question.

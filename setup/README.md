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
| 6 | Auto-merge | `bash setup/turn-on-auto-merge.sh OWNER/REPO ...` (Allow auto-merge plus the variable `AUTO_MERGE=true`; skips a repo unless its ruleset is active and requires checks) |

| 7 | Cloudflare deploys | Recommended: `bash setup/connect-cloudflare-builds.sh OWNER/REPO WORKER_NAME` connects Cloudflare's own Git build, with no secret in GitHub. Or `bash setup/set-cloudflare.sh OWNER/REPO ...` to deploy from GitHub Actions ([docs/cloudflare.md](../docs/cloudflare.md)) |

Optional: the secret `REFERENCE_REPOS_TOKEN`, a read-only token for the repos listed in `.github/reference-repos.txt` ([docs/reference-repos.md](../docs/reference-repos.md)); set it, or any other secret, with `bash setup/set-secret.sh NAME OWNER/REPO ...`.

Optional: the secret `AUTO_MERGE_TOKEN`, if `main` deploys through a workflow ([docs/options.md](../docs/options.md#how-prs-merge)), and the variable `NO_REVIEW_LABEL` for PRs that skip the Claude review on purpose (see `merge-gate.yml`).

## Secrets and sign-ins

What each secret is, where it comes from and where it lives. None of them is ever pasted into a chat.

<!-- loop:secrets -->
- **CLAUDE_CODE_OAUTH_TOKEN**
  - What: Lets the GitHub workflows use your Claude subscription.
  - Comes from: Run `claude setup-token` on your computer.
  - Stored in: GitHub repo secret, set with `setup/set-token.sh`.
  - Used by: The build, review and fix workflows.
  - Expires: About a year. The command shows the date.
- **GitHub CLI sign-in**
  - What: Lets the setup scripts change your repo settings.
  - Comes from: `gh auth login`.
  - Stored in: Your computer's keychain (`gh` keeps it).
  - Used by: The scripts in `setup/`.
  - Expires: Until you sign out.
- **AUTO_MERGE_TOKEN (optional)**
  - What: Merges as you, so a deploy workflow on main still runs.
  - Comes from: GitHub: Settings, Developer settings, fine-grained token for this repo only.
  - Stored in: GitHub repo secret.
  - Used by: The build workflow when it turns on auto-merge.
  - Expires: The date you choose when you create it.
- **CLOUDFLARE_API_TOKEN**
  - What: Lets the deploy workflow publish your site, Workers and database changes. Not needed when Cloudflare's own Git build deploys the repo.
  - Comes from: Cloudflare: Account API tokens, the "Edit Cloudflare Workers" template, limited to your account, plus D1 Edit if you have a database.
  - Stored in: GitHub repo secret, set with `setup/set-cloudflare.sh` (the account ID goes in a repo variable).
  - Used by: The deploy workflow, for previews and when main changes.
  - Expires: The date you choose. Always set one.
- **REFERENCE_REPOS_TOKEN (optional)**
  - What: Lets builds read the other repos listed in `.github/reference-repos.txt`.
  - Comes from: The host of those repos (GitHub or Azure DevOps): a token that can only read code.
  - Stored in: GitHub repo secret, set with `setup/set-secret.sh`.
  - Used by: The build and fix workflows, before Claude starts.
  - Expires: The date you choose. Always set one.
- **App secrets**
  - What: Keys your own code needs at runtime, such as a session key.
  - Comes from: You generate them, or the service that issues them.
  - Stored in: Cloudflare, with `wrangler secret put` (never in the repo).
  - Used by: Your Workers and Pages functions.
  - Expires: When you rotate them, or when the issuer says.
- **Connector sign-ins**
  - What: Let Claude read and write Notion, Linear, GitHub and Cloudflare.
  - Comes from: Sign in from Claude's connector settings.
  - Stored in: Claude (nothing to copy).
  - Used by: Your Claude project and the scheduled reports.
  - Expires: When a service asks you to sign in again.
<!-- /loop:secrets -->

## Example

```sh
claude setup-token
bash setup/set-token.sh   my-org/web my-org/api
bash setup/add-labels.sh  my-org/web my-org/api
# install the apps by hand, merge the first PR, then:
bash setup/add-ruleset.sh my-org/web my-org/api
bash setup/add-ruleset.sh -c "Lint and test" -c "Merge gate" my-org/docs
bash setup/turn-on-auto-merge.sh my-org/web my-org/api my-org/docs
CLOUDFLARE_ACCOUNT_ID=<ACCOUNT ID> bash setup/connect-cloudflare-builds.sh my-org/web web
```

## PRs that change workflow files

The Claude action won't run on a PR that changes its own workflow files, so such a PR never gets a Claude verdict and its Merge gate stays red. This includes updating a repo to a newer version of this template. Merge these by hand, once CI is green:

```sh
bash setup/pause-ruleset.sh OWNER/REPO off
gh pr merge <number> -R OWNER/REPO --merge
bash setup/pause-ruleset.sh OWNER/REPO on
```

Turn the ruleset back on right away. While it is off, any PR can merge, including one waiting on a design question.

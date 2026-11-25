# GitHub Enterprise Cloud

The loop runs as GitHub Actions in each repo, and GitHub's own auto-merge does the merging. [docs/github.md](../docs/github.md) and [setup/README.md](../setup/README.md) cover one repo. This guide adds what an organization owner has to allow first.

This guide is for GitHub Enterprise Cloud on github.com. On a self-hosted GitHub Enterprise Server, or an enterprise with its own data-residency address, the Claude and Codex GitHub apps may not be available. Check both before you plan around them.

## What an organization owner does once

1. **Approve four GitHub apps** for the loop repos only, not the whole organization:

   | App | What it does in the loop |
   |---|---|
   | Claude | Lets the build, review and fix workflows act on issues and pull requests |
   | ChatGPT Codex Connector | The second review |
   | Linear | Links branches and pull requests to Linear issues |
   | Cloudflare Workers and Pages | Deploys and previews, if you use Cloudflare's own Git build |

2. **Set the Actions policy.** If the organization allows only selected actions, add `anthropics/claude-code-action@*`, `pnpm/action-setup@*`, `oven-sh/setup-bun@*` and `ruby/setup-ruby@*`, and allow actions created by GitHub.
3. **Check the workflow permissions.** Each workflow file declares the permissions it needs, so the organization's default can stay read-only. If a build cannot open its pull request, turn on "Allow GitHub Actions to create and approve pull requests" in the organization's Actions settings.
4. **Give the setup person admin rights** on the loop repos, for as long as the setup takes. The scripts in `setup/` change repo secrets, variables, labels, rulesets and the auto-merge setting.
5. **Decide who may add the `claude` label.** Anyone who can label an issue can start a build. In practice that is everyone with triage rights on the repo.

## For each repo

Follow [setup/README.md](../setup/README.md). The scripts take a list, so one command covers every repo:

```sh
gh auth login
bash setup/add-labels.sh  <ORG>/<REPO> <ORG>/<OTHER REPO>
bash setup/add-ruleset.sh <ORG>/<REPO> <ORG>/<OTHER REPO>
bash setup/turn-on-auto-merge.sh <ORG>/<REPO> <ORG>/<OTHER REPO>
```

The Claude token is set per repo by the person it belongs to ([claude-team.md](claude-team.md)).

If your organization uses single sign-on, authorize the `gh` sign-in for the organization when `gh auth login` asks, or the scripts get "resource not accessible" errors.

## Rules that can clash with the loop

Enterprise organizations often have rules of their own. Check these before the first pull request.

- **Required human approvals.** The loop's ruleset requires zero approving reviews, because the design was approved before any code was written. If an organization-wide ruleset requires one, every pull request waits for a person and the loop stops being hands-off. Either exempt the loop repos, or accept that a person clicks approve on each pull request.
- **Organization rulesets.** Keep the loop's `protect main` ruleset at repo level, as the script creates it. The auto-merge script looks for it there and skips a repo without it.
- **Required checks with other names.** If your CI jobs are not named `check`, pass each name: `bash setup/add-ruleset.sh -c "<JOB NAME>" -c "Merge gate" <ORG>/<REPO>`.
- **Signed commits.** If the organization requires them, commits made by the workflows need to satisfy that rule. Test with one pull request before relying on it.
- **IP allow lists.** If the organization restricts access by IP address, GitHub-hosted runners and the installed apps must be allowed, or you need self-hosted runners ([docs/toolchains.md](../docs/toolchains.md#self-hosted-runners)).
- **Fine-grained tokens.** If the organization requires approval for personal access tokens, an owner has to approve any `AUTO_MERGE_TOKEN` before it works.
- **Enterprise Managed Users.** Managed accounts cannot create content outside the enterprise, and some apps need an enterprise owner to install them. Ask your enterprise owner early.

## Existing repos

The loop can be added to a repo that already has code, CI and branch rules:

1. Keep the existing CI. Either rename its main job to `check`, or pass its job names to `add-ruleset.sh`.
2. Put the repo's real install, lint and test commands in `scripts/check.sh`, and add version files so the workflows install the right tools ([docs/toolchains.md](../docs/toolchains.md)).
3. If the repo already has branch protection on `main`, remove it once the `protect main` ruleset is on. Two sets of rules are hard to reason about.
4. Old issues are not built. Only issues that carry the `claude` label and an approved mockup line are.

## Cost

Private repos use the organization's Actions minutes. The workflows are built to use few: CI skips drafts, a new push cancels the run before it, and the Merge gate is a status, not a job. Watch the usage report in the first weeks.

## Check before moving on

- The four apps show the loop repo under their repository access.
- `gh api repos/<ORG>/<REPO>/rulesets` lists `protect main` after the scripts have run.
- A test pull request shows the `check` job and, after the Claude review, a `Merge gate` status.

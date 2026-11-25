# Setting the loop up in an organization

This folder is for a team that is adopting the loop on organization plans: Claude Team, ChatGPT Team, Notion Enterprise, Linear Enterprise, GitHub Enterprise Cloud and Cloudflare, with some code still in Azure DevOps. The main [README](../README.md) explains the loop itself. Read that first.

Nothing here contains account details. Everything in angle brackets is a placeholder for you to fill in.

## Placeholders

| Placeholder | Meaning | Example |
|---|---|---|
| `<ORG>` | Your GitHub organization | `acme` |
| `<REPO>` | A repo that runs the loop | `web` |
| `<TEAM KEY>` | The Linear team key that prefixes issue IDs | `ABC` |
| `<WORKSPACE>` | Your Notion or Linear workspace | |
| `<ACCOUNT ID>` | Your Cloudflare account ID | |
| `<WORKER NAME>` | A Worker's name in its wrangler config | `web` |
| `<AZURE ORG>`, `<PROJECT>` | Your Azure DevOps organization and project | |

## Who is needed

Most steps need an admin of one tool for a few minutes. Line these people up before you start.

| Role | Needed for |
|---|---|
| Claude Team owner | Turning on the connectors and Claude Code for members |
| ChatGPT Team admin | Turning on Codex and its GitHub connection |
| Notion workspace owner | Creating the teamspace, allowing the Claude connection |
| Linear admin | Creating the team and labels, installing the GitHub integration |
| GitHub organization owner | Approving four GitHub apps, the Actions policy, repo admin rights |
| Cloudflare super administrator | Adding members, API tokens, the GitHub app |
| Azure DevOps project administrator | A read-only token for the reference repos |
| A design approver per product | The one person whose approval starts a build |

"The owner" in the README, the prompts and `CLAUDE.md` means the design approver for that product. In a team, name that person in each repo's `CLAUDE.md` and in the Claude project instructions.

## Order

Do the guides in this order. Each one says what to check before moving on.

1. [GitHub Enterprise](github-enterprise.md): apps, Actions policy, the repo.
2. [Claude Team](claude-team.md): seats, connectors, the token for each repo.
3. [ChatGPT Team](chatgpt-team.md): the second review.
4. [Notion Enterprise](notion-enterprise.md): ideas, specs and the design review.
5. [Linear Enterprise](linear-enterprise.md): issues.
6. [Cloudflare](cloudflare.md): deploys.
7. [Azure DevOps](azure-devops.md): read-only reference repos. Skip it if no repo needs one.
8. Add the loop to the first repo: paste [prompts/new-project.md](../prompts/new-project.md) into its Claude project, then run the scripts in [setup/README.md](../setup/README.md).
9. Schedule the morning sync and the weekly retro ([prompts/](../prompts/README.md)).

Start with one repo and one small spec. Add more repos only after one pull request has gone from idea to production without anyone touching it. Every repo gets the same workflows and the same settings, so the setup scripts take a list of repos.

## Whose Claude usage runs what

The loop runs on individual Claude seats. It does not use an organization API key anywhere.

| Work | Runs on |
|---|---|
| Builds, reviews and fix rounds in GitHub Actions | The seat of the person whose token is that repo's `CLAUDE_CODE_OAUTH_TOKEN` |
| Builds on a computer | The seat of the person at that computer |
| Ideas, specs, mockups, cutting issues | The seat of the person in that Claude chat or project |
| Morning sync and weekly retro | The seat of the person who scheduled them |

[claude-team.md](claude-team.md) covers how to pick the person for each repo and what to do when they leave.

## A first run to prove it works

1. Save a small idea in Notion and set it to Spec it.
2. Approve the spec and mockup (Design approved).
3. Check that Claude cut a Linear issue and opened a GitHub issue with a `Linear:` line and the `claude` label.
4. Watch the Actions tab: the build opens a pull request, the Claude and Codex reviews arrive, the Merge gate turns green and the pull request merges.
5. Check the preview address on the pull request and the production deploy after the merge.
6. The next morning, check that the spec in Notion says Shipped.

If a step stalls, the Actions run for that step says why. The most common causes are an app not approved for the repo, a missing secret, and a required check whose name does not match.

## Keeping it healthy

- Keep a list of every token with its owner and expiry date: each repo's Claude token, Cloudflare tokens, the Azure DevOps token, any `AUTO_MERGE_TOKEN`. Renew a week early.
- Never paste a token into a chat. The setup scripts ask for each one in your own terminal and do not show it.
- When someone leaves, replace the tokens they created the same day.
- To update a repo to a newer copy of these files, open a pull request with the changed workflows and merge it by hand ([setup/README.md](../setup/README.md#prs-that-change-workflow-files)).

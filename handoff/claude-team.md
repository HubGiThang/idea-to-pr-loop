# Claude Team

Claude does most of the work in the loop: it sharpens ideas, writes specs and mockups, cuts issues, builds, reviews, fixes, and writes the reports. On a Team plan this runs on members' own seats.

Menu names in admin settings change from time to time. If a setting is not where this guide says, search the settings page for its name.

## What the Team owner sets up once

1. **Seats.** Everyone who approves designs, runs a Claude project or lends a token needs a seat that includes Claude Code. Give the people whose tokens run repos (see below) the highest seat tier, because every build, review and fix in their repos draws on their limits.
2. **Claude Code.** Make sure Claude Code is turned on for the organization, including Claude Code on the web if you want Claude projects to work on repos in the cloud.
3. **Connectors.** In the organization's connector settings, turn on Notion, Linear, GitHub and Cloudflare. Each member then signs in to each one with their own account, so Claude can only see what that person can see.
4. **GitHub.** Connect the organization's GitHub so members can add repos to Claude projects. This is separate from the Claude GitHub app that the workflows use ([github-enterprise.md](github-enterprise.md)).

## A token for each repo

The workflows in a repo sign in to Claude with one secret, `CLAUDE_CODE_OAUTH_TOKEN`. It is a personal token: it belongs to one member and uses that member's seat. Use these individual tokens for every repo. The loop does not need an organization API key, and none of its files reference one.

For each repo, pick one person. A good choice is the design approver for that product, since the work is theirs anyway. Then that person:

1. Installs Claude Code on their computer and signs in with their Team account.
2. Runs `claude setup-token` and keeps the terminal open.
3. Runs `bash setup/set-token.sh <ORG>/<REPO>` and pastes the token when asked. It is not shown and not stored anywhere else.

Things to know:

- **Limits are per person.** If one person's token runs many busy repos, builds queue up behind their limits. Spread repos across people, keep issues small, or raise that person's seat tier.
- **The token lasts about a year.** `claude setup-token` shows the date. Put it in your token list and renew it a week early by running the same two commands.
- **When the person leaves or changes role,** someone else runs the two commands for each of their repos the same day. Removing their seat stops their token, and every build in those repos stops with it.
- **Use repo secrets, not one organization secret.** A repo secret keeps each repo on its own person's seat and makes it obvious whose usage a repo is.

## A Claude project for each product

One project per product, created by the person who drives that product:

1. Add the product's repo to the project.
2. Turn on the Notion, Linear, GitHub and Cloudflare connectors in the project and sign in to each.
3. Paste the text from [prompts/project-instructions.md](../prompts/project-instructions.md) into the project's instructions and fill in the placeholders. Name the design approver.
4. To add the loop to the repo, paste [prompts/new-project.md](../prompts/new-project.md) as the first message.

Share the project with the teammates who work on that product, so they see the same instructions and memory.

## Scheduled reports

The morning sync and the weekly retro are scheduled tasks. One person creates them, once for the whole organization, from [prompts/morning-sync.md](../prompts/morning-sync.md) and [prompts/weekly-retro.md](../prompts/weekly-retro.md). They run on that person's seat and with that person's connector sign-ins, so that person needs to be able to read every loop repo, the Specs database and the Linear team. Note who it is in your token list: if they leave, the reports stop.

## Building on a computer

Any member can build an issue in Claude Code on their own computer with [prompts/build-locally.md](../prompts/build-locally.md). That uses their own sign-in and needs no token setup ([docs/toolchains.md](../docs/toolchains.md#where-a-build-runs)).

## Check before moving on

- A member can open a Claude project, see the repo, and read a page from Notion and an issue from Linear through the connectors.
- The repo has the secret `CLAUDE_CODE_OAUTH_TOKEN`, and you know whose it is and when it expires.

# Linear Enterprise

Linear holds the work items. Claude cuts each approved spec into small issues, and each issue becomes a GitHub issue that starts a build. [docs/linear.md](../docs/linear.md) has the issue format. This guide adds what an organization needs.

## Set it up

1. **Choose the team layout.** Either one Linear team per product, or one team that covers several repos. Both work. With one team for several repos, issue IDs share one prefix and Claude opens the GitHub issues itself, which is the setup this guide assumes.
2. **Create the labels at workspace level,** so every team has them: `claude`, `needs-human` and `bug-fix`. The names must match exactly.
3. **Install the GitHub integration.** A Linear admin and a GitHub organization owner install Linear's GitHub app on the loop repos. Leave GitHub Issues sync off. Keep the pull request automations on: an issue moves to In Progress when its pull request opens and to Done when it merges.
4. **Allow the Claude connection.** If your workspace requires admin approval for third-party apps, approve Claude's. Each member then signs in to Linear from Claude's connector settings.
5. **One Linear project per spec.** Claude creates it when it cuts a spec and writes the project's link back to the spec in Notion. If you track products with Initiatives, add each project to its product's Initiative.

## How an issue reaches GitHub

1. Claude creates the Linear issue with a Mockup line, a Design section and acceptance criteria.
2. Claude opens a GitHub issue in the product's repo with the same title and body, a first line `Linear: <TEAM KEY>-12`, and the `claude` label.
3. The build names its branch `claude/<team key>-12-short-slug` and starts the pull request body with `Fixes <TEAM KEY>-12`, so Linear links the branch and closes the issue on merge.

The GitHub issue must be opened by a person's account or by the Claude GitHub app. An issue opened by a workflow's built-in token does not start a build.

## Things to know

- Edits made in Linear after an issue is cut do not reach GitHub. Change the GitHub issue too, or ask Claude to.
- Do not add the `claude` label by hand to an issue that has no Mockup line. The build refuses it and says why.
- With single sign-on or SCIM, members are managed by your identity provider. Everyone who cuts issues needs to be a member of the team, not a guest.
- A `needs-human` label means a question went back to the spec's Design review in Notion. Nobody needs to answer in Linear.

## Check before moving on

Approve a small test spec and ask Claude to cut it. You should see one Linear project, one or more Linear issues, and matching GitHub issues that each start with a `Linear:` line.

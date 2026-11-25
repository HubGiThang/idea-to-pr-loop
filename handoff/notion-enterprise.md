# Notion Enterprise

Notion is where people decide things: ideas, specs with their mockups, and the one approval that starts a build. [docs/notion.md](../docs/notion.md) has the database fields and the lifecycle. This guide adds what an Enterprise workspace needs.

## Set it up

1. **Allow the connection.** Enterprise workspaces can restrict which connections members may use. A workspace owner allows the Claude connection in the workspace's connection settings. Each member then signs in from Claude's connector settings, and Claude can read and write only what that member can.
2. **Create a teamspace.** Name it for the work, for example "Product". Make it closed, and add the people who write ideas, approve designs and read reports.
3. **Create the four databases and the home page** as [docs/notion.md](../docs/notion.md) describes: Ideas, Specs, Decisions and Retros. The quickest way is to ask Claude, in a chat with the Notion connector on: "Create the databases and home page described in docs/notion.md in the <TEAMSPACE> teamspace."
4. **Add two team fields to Specs:** `Approver` (a person) and `Product` (a select, or a relation to a list of products). With several products in one database, each person filters to their own.
5. **Write the two gates into the database descriptions,** so every Claude session that opens them sees the rules: only a person sets an idea to Spec it, and only the approver sets a spec to Design approved.

## Permissions

- Give design approvers and spec writers edit access to the teamspace. Give everyone else comment access, so they can respond to a mockup without changing a status.
- Notion cannot lock a single field. The Design approved status is protected by who has edit access and by the page history, which shows who changed it. Keep the list of editors short.
- Lock the databases' structure once the fields are right, so a status option is not renamed by accident. The workflows and prompts rely on the exact status names.
- Mockup links may point to private pages. That is fine: each issue's Design section describes the screen in words, so the build and both reviews do not need the link.

## Things to know

- The scheduled reports write to Notion as the person who created them. That person needs edit access to Specs, Retros and the home page.
- If your workspace uses single sign-on, each member signs in through it when they connect Notion to Claude. Nothing extra is needed.
- Audit log and page analytics, both Enterprise features, are the place to look if a status changed and nobody knows why.

## Check before moving on

Ask Claude to save a test idea. It should appear in Ideas with Status Inbox, and Claude should stop there. Set it to Spec it yourself and ask for the spec: it should arrive in Specs with Status Design review and a Mockup link.

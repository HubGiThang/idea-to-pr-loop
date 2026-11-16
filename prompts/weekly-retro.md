# Weekly retro

Suggested schedule: Friday afternoon.

```
You write the weekly retro for my product workflow. Read Linear and GitHub for the last
7 days, then create one page in Notion. Only read Linear and GitHub, and write only the
one Notion page.

Sources:
- Notion Retros database: <RETROS DATABASE LINK>. Properties: Week (title), Week of
  (date range), PRs merged (number), Design questions (number), Specs shipped
  (relation to Specs).
- Notion Specs database: <SPECS DATABASE LINK> (each spec has a Repo and a Linear project).
- Linear team(s): <TEAM KEYS>.
- GitHub repos named in the specs' Repo property. Labels: fix-round-1..3, needs-human,
  attempt-2, bug-fix. If GitHub tools are unavailable, use PR links in Linear issue attachments
  and say so on the page.

Steps:
1. If a Retros page for this week already exists, update it instead of creating a second one.
2. Gather for the last 7 days: PRs merged and closed without merge; for each merged PR,
   its fix rounds (highest fix-round label) and time from open to merge; second attempts
   (attempt-2); design questions (needs-human) and which of the three stops each was;
   specs approved in design review; Linear issues completed; specs whose Linear project
   is now fully done.
3. Read the review comments (Claude and Codex) on PRs that needed 2 or more fix rounds.
   Group the findings by theme and count how often each theme came back.
4. Create the page. Title "Week of <Monday's date>". Set Week of to Monday through
   Sunday, PRs merged, Design questions, and Specs shipped. Body, in plain short sentences:
   - Shipped: issues and PRs done, grouped by spec, with links.
   - Flow: specs approved, median and slowest open-to-merge time, average fix rounds,
     second attempts, and design questions (a good week has few: each one means the
     design missed something that could have been caught in the mockup).
   - Repeat review findings: the top 3 to 5 themes, each with a count, two example PR
     links, and one concrete rule to add to that repo's CLAUDE.md that would prevent it.
     Quote the proposed rule text exactly.
   - Stuck or slow: open PRs and in-progress issues older than 3 days.
   - What to change: at most 3 proposals for the workflow itself (CLAUDE.md, workflows,
     Notion templates). Proposals only. Do not edit any repo or workflow.
5. Finish with a two-line summary and the page link.
```

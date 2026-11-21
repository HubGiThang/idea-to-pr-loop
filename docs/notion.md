# Notion setup

One teamspace (for example "Product") with four databases and one home page. You spend your review time here, early: each spec comes with a clickable mockup, and once you approve it everything else runs on its own. You never need to read a PR.

## Databases

| Database | Properties | Page template |
|---|---|---|
| Ideas | Status (Inbox, Spec it, Specced, Parked, Rejected), Repo, Size (S, M, L), Source | Problem, who it is for, why now, rough size |
| Specs | Status (Drafting, Design review, Design approved, Building, Shipped, Dropped), Mockup (URL), Design approved (date), Repo, Linear project (URL), PRs (text), Blockers (text), Autonomy (Auto-merge, Human merge; default Auto-merge) | Mockup (link and what to look at), goal, non-goals, user stories, acceptance criteria (pointing at mockup screens), hard-to-undo steps (or "none"), architecture, slice plan, risks, open questions |
| Decisions | Spec (relation), Date, Status | Context, options, decision, consequences |
| Retros | Week (title), Week of (date range), PRs merged (number), Design questions (number), Specs shipped (relation to Specs) | Written by the weekly retro task |

## Home page

Make one page you open every morning, with:

1. A heading **Overnight status** with a single callout under it. The morning sync task rewrites only this callout.
2. A heading **Today** with linked views: **Waiting for your design review** (Status = Design review) first, then Ideas in Inbox and Specs in Building.

## Idea gate

Inbox → Spec it → Specced (or Parked, Rejected). Only you set **Spec it**: it is the go-ahead for Claude to draft a spec and mockup. Claude creates ideas in Inbox and stops; it never changes an idea's Status. Put this rule in the Ideas database description too, so every Claude session that opens it sees it.

## Spec lifecycle

Drafting → Design review → Design approved → Building → Shipped (or Dropped).

- **Drafting:** Claude writes the spec and makes the mockup ([prompts/spec-and-mockup.md](../prompts/spec-and-mockup.md)). Architecture and the slice plan are in the spec, but they are Claude's job, not a separate gate.
- **Design review:** your step. Open the mockup, comment or ask for changes, then set **Design approved** and fill in the date. Name any hard-to-undo steps in the spec now; your approval covers them.
- **Design approved:** Claude cuts the spec into Linear issues ([docs/linear.md](linear.md)). From then on, the morning sync moves the spec between Building and Shipped.
- **Back to Design review:** when a build hits one of the three stops (see the CLAUDE.md template), the morning sync moves the spec back here and puts the question and options at the top of the page. Approve it again and the build continues.

Bug fixes that only restore behavior you already approved skip the mockup: they go straight to an issue with the `bug-fix` label.

Autonomy: **Auto-merge** (the default) lets PRs merge once every gate is green. **Human merge** leaves the final click to a person, for repos you don't trust yet.

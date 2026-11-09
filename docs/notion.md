# Notion setup

One teamspace (for example "Product") with four databases and one home page. You spend your planning time here; everything after an approved spec runs on its own.

## Databases

| Database | Properties | Page template |
|---|---|---|
| Ideas | Status (Inbox, Spec it, Parked, Rejected), Repo, Size (S, M, L), Source | Problem, who it is for, why now, rough size |
| Specs | Status (Drafting, Spec approved, Arch approved, Ready to build, Building, Needs you, Shipped, Dropped), Repo, Linear project (URL), PRs (text), Blockers (text), Autonomy (Auto-merge, Human merge) | Goal, non-goals, user stories, acceptance criteria, architecture, slice plan, design, risks, open questions |
| Decisions | Spec (relation), Date, Status | Context, options, decision, consequences |
| Retros | Week (title), Week of (date range), PRs merged (number), Needs-human count (number), Specs shipped (relation to Specs) | Written by the weekly retro task |

## Home page

Make one page you open every morning, with:

1. A heading **Overnight status** with a single callout under it. The morning sync task rewrites only this callout.
2. A heading **Today** with linked views: Specs waiting on you (Drafting, Spec approved, Arch approved, Needs you), Ideas in Inbox, and Specs in Building.

## Spec lifecycle

Drafting → Spec approved → Arch approved → Ready to build → Building → Shipped (or Needs you while something is blocked). People move a spec up to Ready to build. From then on, the morning sync moves it between Building, Needs you and Shipped.

Autonomy decides who merges: **Auto-merge** lets Claude merge PRs that pass every gate; **Human merge** leaves the final click to a person. Start a new repo on Human merge until you trust it.

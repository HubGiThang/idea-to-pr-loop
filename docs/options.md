# Options

## Keep Claude attribution out

By default Claude Code may add a `Co-Authored-By` line to commits and a footer to PR descriptions. To turn that off:

1. In each workflow, uncomment the `settings:` line under `anthropics/claude-code-action@v1`.
2. In `CLAUDE.md`, uncomment the attribution rule under Git, so Claude also leaves it out of comments and files.

## How much Claude may merge

- **Human merge (default):** don't create the `auto-merge` label. Claude builds, reviews and fixes; a person merges.
- **Auto-merge:** add the `auto-merge` label to PRs whose spec has Autonomy = Auto-merge. A Claude session may then merge a PR once every check (including Merge gate) is green, every review thread is resolved, there is no `needs-human` label, and the latest Claude review ends "Verdict: ready to merge". Nothing in the GitHub Actions workflows merges on its own; the merge is done by a Claude session working on the repo (for example in a Claude project), following the rule in CLAUDE.md.

## Number of fix rounds

`claude-fix.yml` stops after 3 rounds. To change it, edit the `for i in 1 2 3` loop, the `-ge 3` check and the two `'3'` comparisons in that file.

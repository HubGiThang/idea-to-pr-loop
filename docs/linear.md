# Linear setup

1. Create one Linear team per repo (Settings → Teams → Create team). Its key (for example ABC) prefixes every issue ID and every branch name.
2. In that team, create the labels `claude`, `needs-human` and `bug-fix`.
3. Settings → Integrations → GitHub: connect the repo to the team and turn on **GitHub Issues sync**, so each Linear issue appears as a GitHub issue with its labels. This is what starts a build: adding `claude` in Linear adds it on GitHub, and `claude.yml` picks it up.
4. In the same integration, keep the default branch and PR automations: an issue moves to In Progress when its PR opens, In Review when the PR is ready, and Done when it merges.

## Several repos, one team

Linear syncs each team's issues to one repo only. If several repos share a team, turn GitHub Issues sync off and let Claude open the GitHub issues instead:

1. Install the Linear GitHub app on all repositories, so "Fixes ABC-12" in any repo's PR links and closes the Linear issue.
2. When Claude cuts a spec, it creates each Linear issue, then opens a GitHub issue in the spec's repo with the same title and body, a first line `Linear: ABC-12`, and the labels (`claude`, or `bug-fix`). It attaches the GitHub issue's link to the Linear issue.
3. The build reads the Linear ID from that line, and the PR's `Closes #N` closes the GitHub issue when it merges.

Edits made in Linear after that don't reach GitHub. Change the GitHub issue too, or ask Claude to.

## Cutting a spec into issues

Issues come only from specs marked **Design approved**. Ask Claude (with the Notion and Linear connectors) to cut the spec up: one Linear project named after the spec, one issue per slice of the slice plan, and the Linear project URL written back to the spec. Without the sync, Claude also opens the GitHub issues (see above). Keep slices to a few hours of work each. Each issue body has:

```
Mockup: <link to the approved mockup>

## Design
<What this slice's screen or behavior looks like in the mockup, in words: layout, labels, states,
example inputs and outputs. The build and the reviews work from this, since the mockup link may be private.>

## Acceptance criteria
- ...
```

Claude adds the `claude` label itself once the issues are cut; you don't need to look at the list. A bug fix that restores approved behavior gets `bug-fix` instead of a Mockup line.

When an issue or PR gets `needs-human`, its question goes back to the spec's Design review. After you approve the spec again, a Claude session removes the label and adds `claude` again to rebuild.

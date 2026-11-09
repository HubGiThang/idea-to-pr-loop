# Linear setup

1. Create one Linear team per repo (Settings → Teams → Create team). Its key (for example ABC) prefixes every issue ID and every branch name.
2. In that team, create the labels `claude` and `needs-human`.
3. Settings → Integrations → GitHub: connect the repo to the team and turn on **GitHub Issues sync**, so each Linear issue appears as a GitHub issue with its labels. This is what starts a build: adding `claude` in Linear adds it on GitHub, and `claude.yml` picks it up.
4. In the same integration, keep the default branch and PR automations: an issue moves to In Progress when its PR opens, In Review when the PR is ready, and Done when it merges.

## Cutting a spec into issues

When a spec reaches Ready to build, ask Claude (with the Notion and Linear connectors) to cut it up: one Linear project named after the spec, one issue per slice of the slice plan, each with acceptance criteria copied from the spec, and the Linear project URL written back to the spec's Linear project property. Keep slices to a few hours of work each. Review the list, then add the `claude` label to the issues you want built.

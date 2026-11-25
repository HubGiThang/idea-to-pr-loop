# Build locally prompt

Paste this into Claude Code, opened in the repo on your computer, to build one issue there instead of in GitHub Actions. Replace everything in angle brackets first. Leave the `claude` label off the issue until the pull request is open, so Actions does not build it a second time.

```
Build GitHub issue #<NUMBER> in this repo, following CLAUDE.md.

1. Read the issue and its comments. Stop and tell me if it has the needs-human label, if it has
   neither a "Mockup: <link>" line nor the bug-fix label, or if a pull request for it already exists.
2. If .github/reference-repos.txt lists repos, run `bash scripts/reference-repos.sh` and treat
   .reference/ as read-only context.
3. Create the branch claude/<linear-id-lowercase>-<short-slug> from the latest main. The Linear ID
   is on the issue's "Linear:" line.
4. Build what the acceptance criteria and the Design section describe. Run ./scripts/check.sh until
   it passes. If a tool it needs is missing on this computer, tell me which one; don't work around it.
5. Commit with a plain imperative message, push the branch, and open a draft pull request against
   main. Its body starts with four lines: "Fixes <Linear ID>", "GitHub issue: #<NUMBER>",
   "Closes #<NUMBER>" and the issue's "Mockup:" line. Then say what changed and how it was checked.
6. When the checks pass, mark the pull request ready. The reviews, fix rounds and merge run in
   GitHub from there.

Decide small open points yourself and note them in the pull request. Stop and ask me only for the
three things CLAUDE.md lists under "When to stop and ask". Never push to main, and never deploy.
```

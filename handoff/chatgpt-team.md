# ChatGPT Team

ChatGPT's Codex gives every pull request a second review, independent of Claude's. The Merge gate waits for it to finish. It never builds or merges anything.

## Set it up

1. **Turn Codex on.** A workspace admin checks that Codex is enabled for the workspace and that members may connect GitHub.
2. **Connect GitHub.** In Codex settings, connect GitHub and install the ChatGPT Codex Connector app on your GitHub organization, for the loop repos only. A GitHub organization owner has to approve the app ([github-enterprise.md](github-enterprise.md)).
3. **Turn on automatic reviews.** In Codex settings, under code review, turn on automatic review for each loop repo. Codex then reviews a pull request when it opens for review or when a draft is marked ready. Anyone can ask for another pass by commenting `@codex review`.
4. **Give it the rules.** Codex reads `AGENTS.md` if the repo has one. A short file that says "Review against the linked issue's Design section and acceptance criteria; see CLAUDE.md" keeps both reviewers on the same design.

## Things to know

- Reviews count against your workspace's Codex usage. Check in the workspace settings whose usage that is, and watch it during the first weeks.
- Codex leaves its findings as review threads. Claude's fix rounds answer them like any other thread, and the Merge gate stays closed while one is unresolved.
- Codex reviews when a pull request opens, not on every push, so the gate only needs it to have finished once.

## Without Codex

If a repo will not have the Codex app, set the repository variable `CODEX_REVIEW` to `off`, or the Merge gate waits forever:

```sh
gh variable set CODEX_REVIEW -R <ORG>/<REPO> --body off
```

## Check before moving on

Open a small test pull request in a loop repo and mark it ready. Within a few minutes Codex should react to it or leave a review.

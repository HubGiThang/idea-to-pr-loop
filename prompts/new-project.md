# New project prompt

Paste as the first message in a new Claude project that has the new repo added and the Notion, Linear and GitHub connectors on.

```
This project builds <PRODUCT NAME> in the repo <OWNER/REPO>. The spec is in Notion,
Specs database: <SPEC LINK>. The Linear team for it is <TEAM KEY>.

Set up the idea-to-pr-loop workflow from <OWNER/idea-to-pr-loop>, then start the build.
Take it one step at a time: tell me what you are about to do before each step that
changes something outside the repo, and wait for my go-ahead.

1. Read the spec. If it is not marked Spec approved or later, or the acceptance criteria
   are unclear, ask me and stop.
2. In the new repo, on a branch, add:
   - .github/workflows/ from idea-to-pr-loop, unchanged.
   - scripts/check.sh with the install, lint, typecheck, build and test commands for the
     stack the spec chooses, and any language setup ci.yml needs.
   - CLAUDE.md from CLAUDE.md.template, with our Linear team key and commands filled in.
   Open it as a draft PR and tell me when it is up.
3. After I merge the setup PR, cut the spec into small Linear issues in team <TEAM KEY>,
   one slice each, each with acceptance criteria, in a new Linear project named after
   the product. Write the Linear project link back onto the Notion spec. Show me the
   list before adding the `claude` label to any of them.
4. Save the repo, Linear team, spec link and these rules to project memory.
```

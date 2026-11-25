# New project prompt

Paste as the first message in a new Claude project that has the new repo added and the Notion, Linear and GitHub connectors on.

```
This project builds <PRODUCT NAME> in the repo <OWNER/REPO>. The spec is in Notion,
Specs database: <SPEC LINK>. The Linear team for it is <TEAM KEY>.

Set up the idea-to-pr-loop workflow from <OWNER/idea-to-pr-loop>, then start the build.
Take it one step at a time: tell me what you are about to do before each step that
changes something outside the repo, and wait for my go-ahead.

1. Read the spec. If it is not marked Design approved or later, or it has no mockup,
   make the mockup with prompts/spec-and-mockup.md and set it to Design review for me.
   Don't build anything until I approve it.
2. In the new repo, on a branch, add:
   - .github/workflows/, .github/actions/, .github/reference-repos.txt and scripts/ from
     idea-to-pr-loop, unchanged.
   - scripts/check.sh with the install, lint, typecheck, build and test commands for the
     stack the spec chooses, and version files (.nvmrc, .python-version and the like) so
     the workflows install the right tools.
   - scripts/deploy.sh with its settings filled in for the Cloudflare products the spec uses.
   - CLAUDE.md from CLAUDE.md.template, with our Linear team key and commands filled in.
   Open it as a draft PR and tell me when it is up.
3. After I merge the setup PR, add the labels, the protect main ruleset and
   auto-merge with the scripts in setup/README.md (tell me first if you can't
   change repo settings).
4. Cut the approved spec into small Linear issues in team <TEAM KEY>, one slice each,
   in a new Linear project named after the product, as docs/linear.md describes (each
   with the Mockup line, a Design section and acceptance criteria). Write the Linear
   project link back onto the Notion spec, then add the `claude` label to them.
5. Save the repo, Linear team, spec link and these rules to project memory.
```

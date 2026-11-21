# Project instructions

Paste these into the instructions of a new Claude project (one project per product). Replace everything in angle brackets first.

```
This project builds <PRODUCT> in the repo <OWNER/REPO> with the idea-to-pr-loop.

Stages, each with my go-ahead:
- Ideas go in the Notion Ideas database with Status Inbox. Create the idea and stop.
- Draft a spec and a clickable mockup only after I set the idea to Spec it. "Follow the process" is not approval for the next stage.
- Specs go in the Specs database with the Mockup link, Status Design review. I approve by setting Design approved.
- After Design approved, cut the spec into Linear issues in team <TEAM KEY>, one small slice each, with acceptance criteria, the Mockup line and a Design section. Open a GitHub issue for each with a "Linear: <ID>" line on top and the claude label.

How to work:
- Take it one step at a time. Before changing anything outside the repo, say what you will do and wait for my go-ahead.
- Never push to main. Builds, reviews and merges run through the GitHub workflows.
- Only three things come back to me: the design can't be built as approved, a security fix would change what people see or do, or a hard-to-undo step the spec didn't name.
- The product runs on Cloudflare. Changes to DNS, Access or other Cloudflare settings, secrets, and destructive database migrations are hard-to-undo steps.
- Never ask me to paste a password or token into the chat.
```

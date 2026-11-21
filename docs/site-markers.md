# Site markers

A public page reads this template to explain the loop. It finds each section between a pair of HTML comments, `<!-- loop:NAME -->` and `<!-- /loop:NAME -->`. Headings and wording inside can change; the marker names and the item fields below are what the page relies on. Keep the markers when you edit the text.

| Marker | File | Items | Fields per item |
|---|---|---|---|
| `loop:idea` | README.md | One block: the idea step | Text; **Actors**; **What Claude helps you sharpen** (sub-list of `Name: text`); **Try saying** |
| `loop:steps` | README.md | Numbered list, steps 2 to 9 | Number; **Title**; actors in parentheses; text |
| `loop:comes-back` | README.md | Bullet list | **Title**; text |
| `loop:guardrails` | README.md | Bullet list | Text |
| `loop:cloudflare` | README.md | Bullet list | **Name**; text |
| `loop:setup` | README.md | Numbered list, one per setup step | Number; **Title**; account in parentheses; text; sub-bullets `Command:`, `Copy:`, `More:` (any number) and `Link:` |
| `loop:secrets` | setup/README.md | Bullet list, one per secret | **Name**; sub-bullets `What`, `Comes from`, `Stored in`, `Used by`, `Expires` |

Other files the page reads whole: `prompts/get-started.md` (the starter prompt) and `prompts/project-instructions.md` (the Claude project instructions). Each holds its text in the one fenced block.

A `Link:` that starts with `http` is a web address; any other value is a path in this repo.

## Telling the site about changes

`.github/workflows/site-dispatch.yml` (kept at `setup/site-dispatch.yml` until a person moves it, because the Claude app can't push workflow files) runs on every push to main and sends a `repository_dispatch` event of type `template-updated`, with the commit SHA in `client_payload.sha`, to the site repo. It needs the secret `SITE_DISPATCH_TOKEN` (a token that can create dispatch events on the site repo) and the repo variable `SITE_REPO` (`OWNER/REPO`). If either is missing it skips with a notice, so copies of the template are not affected.

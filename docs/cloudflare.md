# Cloudflare setup and deploys

Cloudflare runs what the loop ships. Once this is set up, a merge to `main` reaches production with nobody doing anything, and every pull request gets a preview address.

`scripts/deploy.sh` is the one deploy command. Fill in its settings at the top (the build command, D1 databases to migrate, and the Pages project if you use Pages). Everything below runs that script.

## Choose one deploy route per repo

| | Cloudflare's own Git build (recommended) | GitHub Actions |
|---|---|---|
| How it works | Cloudflare watches the repo, builds and deploys | `.github/workflows/deploy.yml` runs Wrangler |
| Secret in GitHub | none | `CLOUDFLARE_API_TOKEN` |
| Previews | a preview per branch, with a comment and a check on the pull request | a preview per ready pull request, with the address in the run summary |
| Works with auto-merge | always | needs the `AUTO_MERGE_TOKEN` secret, because a merge made by the built-in token starts no workflow on `main` ([options](options.md#how-prs-merge)) |
| Choose it when | almost always | the deploy needs steps or tools Cloudflare's build does not have |

## Once per account

1. Add your domain to Cloudflare and switch its nameservers.
2. Note your account ID (Workers & Pages overview, or the address bar of the dashboard).
3. Turn on the Cloudflare connector in Claude, so it can check deploys, databases and logs.

## Route 1: Cloudflare's own Git build

1. Deploy the Worker once from your computer, so it exists: `npx wrangler login`, then `./scripts/deploy.sh production`. Its name must match `name` in the repo's wrangler config.
2. In the dashboard, open Workers & Pages, pick the Worker, then Settings, Builds, Connect. Choose GitHub and install the Cloudflare app on the repo. An organization owner may have to approve the app.
3. Connect the repo. Either finish in the dashboard, or run the script, which sets the same values through the API:

   ```sh
   CLOUDFLARE_ACCOUNT_ID=<ACCOUNT ID> bash setup/connect-cloudflare-builds.sh OWNER/REPO WORKER_NAME
   ```

   In the dashboard the values are: build command empty, deploy command `./scripts/deploy.sh production`, preview command `./scripts/deploy.sh preview`, and builds for preview branches on.
4. Check the build token. The one Cloudflare creates can change Workers, KV, R2 and routes. If the repo uses D1, use a token that also has D1 Edit, or migrations fail.

A Pages project connects the same way from its own Settings, Builds page.

The script needs a user API token with Workers Builds Configuration: Edit and Workers Scripts: Read. It asks for it once and does not store it.

## Route 2: GitHub Actions

1. Create an API token: in the dashboard, Account API tokens, Create Token, the "Edit Cloudflare Workers" template. Limit it to your one account and the zones the repo uses, add D1 Edit if the repo has a database, and set an expiry date.
2. Store it and switch the workflow on:

   ```sh
   bash setup/set-cloudflare.sh OWNER/REPO
   ```

3. If the repo uses auto-merge, add `AUTO_MERGE_TOKEN` so the workflow runs after a merge: `bash setup/set-secret.sh AUTO_MERGE_TOKEN OWNER/REPO`.

## What a deploy does

- **Production** (push to `main`): runs the build command, applies new D1 migrations, then deploys. Migrations only add things, so applying them before the new code is safe. A migration that drops data is a hard-to-undo step and needs the spec to name it.
- **Preview** (any other branch): builds and uploads a preview. It never runs migrations against the production database. Give previews their own bindings in the Worker's preview settings if they must not share production data.

## Runtime secrets and settings

- Keys the code needs at runtime are set once with `npx wrangler secret put NAME`. The repo never holds one.
- Bindings (D1, R2, KV) live in the wrangler config, so they arrive through pull requests like any other change.
- DNS records, Access policies and other dashboard settings are hard-to-undo steps. Claude changes them only when the approved spec names them.
- Put sign-in (Cloudflare Access) in front of admin pages, staging and previews.

## Checking a deploy

Ask Claude, with the Cloudflare connector on: "Did the last deploy of <WORKER NAME> succeed, and what do its logs show?" Or open the Worker's Deployments tab. To undo a bad deploy, roll back to the previous version there, then fix forward with a new issue.

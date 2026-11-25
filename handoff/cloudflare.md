# Cloudflare

Cloudflare hosts what the loop ships and deploys it. [docs/cloudflare.md](../docs/cloudflare.md) has the steps for one repo: the two deploy routes, the scripts and what a deploy does. This guide adds what an organization needs.

## Set it up

1. **One account for the organization.** Use an account owned by the organization, not one person's. Add members with the least role that works: a Workers role for people who deploy, a read-only role for people who only look.
2. **Single sign-on.** If you have it, turn on dashboard SSO for your email domain before adding members.
3. **Domains.** Add each domain and switch its nameservers. From then on a DNS change is a hard-to-undo step that Claude makes only when an approved spec names it.
4. **Choose the deploy route** per repo ([docs/cloudflare.md](../docs/cloudflare.md#choose-one-deploy-route-per-repo)). Cloudflare's own Git build is the default: nothing is stored in GitHub, and each pull request gets a preview address and a check.
5. **Install the Cloudflare GitHub app** on the loop repos, when the first Worker is connected. A GitHub organization owner approves it.
6. **Turn on the Cloudflare connector in Claude,** so members can ask Claude about deploys, databases and logs with their own Cloudflare sign-in.

## Tokens

| Token | Kind | Used for | Notes |
|---|---|---|---|
| Build token | Created by Cloudflare when a repo is connected | Cloudflare's own Git build | Add D1 Edit if the repo has a database |
| Builds API token | A user token: Workers Builds Configuration Edit, Workers Scripts Read | Running `setup/connect-cloudflare-builds.sh` | Needed only while connecting repos. Delete it afterwards |
| Deploy token | An account-owned token from the "Edit Cloudflare Workers" template | The GitHub Actions route (`CLOUDFLARE_API_TOKEN`) | Limit it to the account and zones in use. Set an expiry |

Prefer account-owned tokens where Cloudflare allows them, so a deploy does not depend on one person's membership. Give every token an expiry date and put it in your token list.

## Production and everything else

- Previews share the Worker's bindings unless you give them their own in the Worker's preview settings. If production data must stay out of previews, give previews a separate database and bucket.
- Put Cloudflare Access in front of previews, staging and admin pages, with a policy that lists your people or your identity provider's groups.
- For a stricter split, use a second Cloudflare account for production and a wrangler environment per account. Start with one account unless a policy requires two.

## Things to know

- Cloudflare's build has its own monthly allowance of build minutes, separate from GitHub Actions.
- A Worker's name in the dashboard must match `name` in the repo's wrangler config, or its builds fail.
- Runtime secrets are set once per Worker with `npx wrangler secret put <NAME>`, by a person, in their own terminal. They are never in the repo and never in a chat.
- To undo a bad deploy, roll back in the Worker's Deployments tab. Then open an issue for the fix.

## Check before moving on

Merge a one-line change through the loop. The pull request should show a preview address, and the Worker's Deployments tab should show a new production deploy a few minutes after the merge.

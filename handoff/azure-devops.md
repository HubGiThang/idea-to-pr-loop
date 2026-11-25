# Azure DevOps

The loop runs on GitHub. Its build, its two reviews, the Merge gate and auto-merge all work on GitHub pull requests, and they have no equivalent on Azure Repos. So Azure DevOps repos take part in one way: as read-only reference. Claude can read them while it builds in a GitHub repo, and it never writes to them.

Typical uses: a new service on GitHub that must match an API in an Azure repo, shared libraries that still live in Azure, or a system being moved to GitHub one piece at a time.

## Set it up

1. **Create a read-only token.** In Azure DevOps, open User settings, Personal access tokens, New token. Choose your organization, the scope **Code: Read** and nothing else, and an expiry date. If you can, create it from a service account that has Reader access to only the projects needed, so it does not depend on one person.
2. **List the repos** in `.github/reference-repos.txt` in the GitHub repo that needs them. Use the https clone URL, with no user name in it, and an optional folder name:

   ```
   https://dev.azure.com/<AZURE ORG>/<PROJECT>/_git/<REPO> legacy-api
   ```

   This file changes through a pull request like any other.
3. **Store the token** as the GitHub repo secret `REFERENCE_REPOS_TOKEN`:

   ```sh
   bash setup/set-secret.sh REFERENCE_REPOS_TOKEN <ORG>/<REPO>
   ```

4. **Say what they are for** in the repo's `CLAUDE.md`, in a line or two: which reference repo holds what, and what the new code must match. Claude reads faster with a pointer.

Before each build and fix round, the workflow copies each listed repo into `.reference/<folder>`. [docs/reference-repos.md](../docs/reference-repos.md) explains what keeps the copies read-only.

## On a computer

Someone building locally runs `bash scripts/reference-repos.sh`. It uses the git sign-in their computer already has for Azure DevOps, so no token is needed.

In a Claude chat or project, Claude can only see repos connected through GitHub. To discuss Azure code there, paste the relevant files or work in Claude Code on a computer that has the repo.

## Things to know

- **One token for all reference repos.** The same secret is sent to every listed URL, so keep private reference repos on one host. Public repos need no token.
- **Tokens expire.** Azure DevOps personal access tokens last a year at most, and your organization may set less. When one expires, builds still run, with a warning that a reference repo could not be fetched. Put the date in your token list.
- **Conditional access.** If your Azure DevOps organization restricts access by IP address or device, GitHub's hosted runners may be blocked. Use a self-hosted runner inside your network, or mirror the reference repo to a private GitHub repo and list that instead.
- **Work items.** The loop tracks work in Linear. If people still follow Azure Boards, connect Azure Boards to GitHub and mention `AB#<ID>` in a pull request to link it to a work item. That is optional and changes nothing in the loop.
- **Pipelines.** Azure Pipelines can keep building and deploying the Azure repos as it does today. The loop does not touch them.

## Moving a repo to GitHub

A repo that should get the full loop has to live on GitHub. When you are ready to move one:

1. Create an empty private repo in your GitHub organization.
2. Copy the history: `git clone --mirror <AZURE URL>`, then `git push --mirror <GITHUB URL>` from inside the clone.
3. Make the Azure repo read-only (or disable it), so there is one place to push.
4. Add the loop to the GitHub repo as for any existing repo ([github-enterprise.md](github-enterprise.md#existing-repos)).

Moving a repo is a hard-to-undo step. Plan it with the people who use the repo, not inside a build.

## Check before moving on

Run the build for a small issue and open its Actions log. The "Fetch reference repos" step should say "Fetched <folder>" for each repo you listed.

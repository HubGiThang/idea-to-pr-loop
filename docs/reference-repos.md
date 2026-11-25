# Reference repos

Sometimes Claude needs to read code that lives somewhere else: a shared library, an older system the new one must match, an API another team owns. Reference repos give it that, read-only. They can be on GitHub, Azure DevOps or any host that serves git over https.

## How it works

1. List the repos in `.github/reference-repos.txt`, one per line: an https clone URL, then an optional folder name.

   ```
   https://github.com/<ORG>/<REPO>.git
   https://dev.azure.com/<ORG>/<PROJECT>/_git/<REPO> legacy-api
   ```

2. For private repos, add the secret `REFERENCE_REPOS_TOKEN`: a token that can only read code.

   ```sh
   bash setup/set-secret.sh REFERENCE_REPOS_TOKEN OWNER/REPO
   ```

3. Before each build and each fix round, the workflow copies every listed repo into `.reference/<folder>`. Claude reads them like any other files.

On your computer, `bash scripts/reference-repos.sh` does the same with your own git sign-in.

## What keeps it read-only

- Each copy is a snapshot of the default branch with its git history removed, so there is nothing to push to.
- `.reference/` is kept out of every commit.
- The token should have read access to code and nothing else, limited to the listed repos. Then even a mistake cannot change them.
- The workflows read the list and the script from the default branch, so a pull request cannot send the token to a new address. Changing the list is itself a reviewed pull request.

## Limits

- One token covers every listed repo, so they need to be on one host, or the others need to be public.
- The loop itself (build, reviews, fix rounds, Merge gate, auto-merge) runs only on the GitHub repo it is installed in. A reference repo is something to read, not a place the loop opens pull requests.
- Large repos slow each build down. List only what the work needs.

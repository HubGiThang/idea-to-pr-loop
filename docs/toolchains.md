# Toolchains and where builds run

A build needs the repo's languages and tools installed. The loop keeps one rule: `./scripts/check.sh` is the only command that says "this change is good", and it runs the same way on a laptop and in GitHub Actions.

## What GitHub Actions installs

CI, the Claude build and the Claude fix rounds all start with the shared step `.github/actions/setup-toolchains`. It looks at the files in the repo and installs only what they call for, with caches on.

| Toolchain | Switched on by | Version comes from |
|---|---|---|
| Node | `package.json`, `.nvmrc` or `.node-version` | `.nvmrc` or `.node-version`, else the current LTS |
| pnpm | `pnpm-lock.yaml` | `packageManager` in `package.json`, else the latest |
| Yarn | `yarn.lock` | `packageManager` in `package.json` (through Corepack) |
| Bun | `bun.lock` or `bun.lockb` | the latest |
| Python | `.python-version`, `pyproject.toml`, `requirements*.txt`, `Pipfile`, `uv.lock` or `poetry.lock` | `.python-version`, else the latest 3.x |
| uv, Poetry | `uv.lock`, `poetry.lock` | the latest |
| .NET | `global.json` | `global.json` |
| Java | `.java-version`, `pom.xml` or `build.gradle` | `.java-version`, else 21 (Temurin) |
| Go | `go.mod` | `go.mod` |
| Ruby | `Gemfile` | `.ruby-version` or `.tool-versions`, else the latest |
| Rust | `Cargo.toml` | `rust-toolchain.toml`, else the runner's stable |

GitHub's runner image already has current .NET SDKs, Java, PHP with Composer, Rust, Go, Docker, the Azure CLI and the GitHub CLI. A .NET repo without `global.json`, or a PHP repo, builds with those and needs nothing here.

Pin versions with the version files. That is what keeps a laptop, CI and Claude on the same toolchain.

The step installs tools only. Installing the repo's own packages (`pnpm install`, `pip install -r requirements.txt`, `dotnet restore`) belongs in `scripts/check.sh`, because Claude's workflows may run that script and nothing else.

### Adding a tool that is not listed

Add a step to `.github/actions/setup-toolchains/action.yml`, so every workflow gets it at once. A pull request that changes only this file is reviewed and merged like any other. If the tool is a download, pin its version.

### Organizations that restrict actions

If the organization only allows listed actions, allow these: `actions/*`, `anthropics/claude-code-action`, `pnpm/action-setup`, `oven-sh/setup-bun` and `ruby/setup-ruby`. The last three run only in repos that use pnpm, Bun or Ruby.

## Where a build runs

There are two places Claude can build an issue. Both follow the same rules in `CLAUDE.md` and open the same kind of pull request, so the reviews, the fix rounds, the Merge gate and the merge are identical.

| | In GitHub Actions | On your computer |
|---|---|---|
| Starts when | the issue gets the `claude` label | you paste [prompts/build-locally.md](../prompts/build-locally.md) into Claude Code in the repo |
| Uses | the repo's `CLAUDE_CODE_OAUTH_TOKEN` | your own Claude sign-in |
| Toolchains | installed by the shared step | whatever your computer has |
| Good for | most issues; nothing to keep open | work that needs local tools, a VPN, a device, or a long debugging session |

Use either, or both across different issues. Never both on the same issue: when you build one locally, leave the `claude` label off until your pull request is open, so Actions does not start a second build. After the pull request opens, the reviews and fix rounds run in Actions as usual.

To run the checks locally, install the versions in the repo's version files, then run `./scripts/check.sh`. A version manager such as mise or asdf reads the same files.

### Self-hosted runners

If builds must run inside your own network, change `runs-on: ubuntu-latest` in the workflows to your runner's label. The shared toolchain step works there as long as the runner can download tools, or already has them.

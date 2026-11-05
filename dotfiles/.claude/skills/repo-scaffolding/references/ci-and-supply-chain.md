# CI, hooks and supply-chain security

## Security gates

| What | Tool | Where |
| --- | --- | --- |
| Secrets in code and history | `gitleaks`; `detect-private-key` hook | Pre-commit and CI (full history) |
| Known-vulnerable dependencies | `pip-audit`, `npm audit --audit-level=high`, or `osv-scanner` for anything | CI on every run plus the daily schedule; pre-push |
| Static analysis of code | `semgrep` with `p/default` plus language packs, or CodeQL; ruff `S` or `eslint-plugin-security` as the cheap first line | CI |
| GitHub Actions workflows | `zizmor` (security: unpinned refs, injection, excessive permissions) and `actionlint` (validity) | Pre-commit and CI |
| Containers | `hadolint` for Dockerfiles, `trivy` for image and filesystem scans | CI |
| Shell | `shellcheck`, `shfmt` | Pre-commit and CI |
| Lockfile integrity | `uv lock --check`, `npm ci`, `pnpm install --frozen-lockfile` | Pre-commit and CI |
| Supply-chain config | Dependabot `cooldown`, `npm config ignore-scripts` unless an install script is needed | Repo config |

Run the audits with the lockfile as the source, so the audit covers exactly
what gets installed, dev tooling included.

## Workflow rules

- `permissions: contents: read` at the top, widened per job only where needed.
- `actions/checkout` with `persist-credentials: false`.
- Actions pinned by full commit SHA with the tag in a trailing comment.
- Untrusted values (`github.head_ref`, PR titles, issue bodies) go into `env:`,
  never straight into `run:`.
- `timeout-minutes` on every job; `concurrency` cancelling superseded PR runs.
- Triggers: `pull_request`, `push` to the default branch, a daily `schedule`
  and `workflow_dispatch`.
- A frozen lockfile in CI (`UV_FROZEN=1`, `npm ci`) so a stale lock fails
  rather than silently resolving new versions.
- One job per gate (a matrix is fine), so a failure names the gate.
- An aggregate job, named `ci`, with `needs: [every other job]`, `if: always()`
  and a step that fails unless every result is `success` or `skipped`. It is the
  only required status check in the branch ruleset.

## Pre-commit

- Hygiene hooks from `pre-commit-hooks`: `check-added-large-files`,
  `check-case-conflict`, `check-merge-conflict`, `check-yaml`, `check-toml`,
  `check-json`, `detect-private-key`, `end-of-file-fixer`, `mixed-line-ending`,
  `trailing-whitespace`.
- `gitleaks`, `zizmor --offline`, `actionlint`, `shellcheck`, `hadolint`.
- The project's formatter, linter, type checker and lockfile check as `local`
  hooks through the project's runner.
- Default install types `[pre-commit, pre-push]`: fast gates on commit, tests
  and audits on push.
- Hook revisions are pinned and kept current by Dependabot or `pre-commit
  autoupdate`.

## Dependabot

- One ecosystem entry per package manager plus `github-actions`.
- Daily checks timed just before the scheduled audit for the language
  ecosystem, so an advisory is fixed as soon as it lands.
- `cooldown: default-days: 7` (security updates ignore it).
- A group for dev-tooling minor and patch updates, separate from runtime
  dependencies, so a failing linter bump never blocks a security fix.

## Repository settings

Record these in `AGENTS.md` and apply with `gh api` or a ruleset: require the
`ci` check, require branches to be up to date, require linear history or squash
merges, require signed commits if the owner uses them, restrict force pushes
and deletion of the default branch, and enable secret scanning with push
protection and Dependabot alerts.

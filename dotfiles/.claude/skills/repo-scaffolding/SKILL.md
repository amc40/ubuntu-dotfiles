---
name: repo-scaffolding
description: Set up a new repository, or audit and harden an existing one, with the owner's preferred automated quality gates - strict typing, language and framework linters, formatting, architecture enforcement (DDD), security scanning, and layered test coverage - wired into one local command, pre-commit hooks and CI. Use when asked to scaffold, bootstrap or initialise a repo or project, add tooling or CI to one, or check which quality gates are missing.
---

# Repo scaffolding preferences

The aim is the maximum practical number of **automated** gates, so that review
spends its time on design and not on style, types or missing tests. A rule that
lives only in a document or in someone's head is not a gate. Prefer the
strictest setting that can be met today, and write the reason beside every
exception.

## Gates every repo gets

| Concern | Requirement |
| --- | --- |
| Typing | The compiler or checker's strictest mode, plus the extra flags strict leaves off. No untyped escape hatches without a justified, coded suppression. |
| Language lint | The full rule set, minus only rules that conflict with the formatter or each other. New rules in future releases must be opt-out, not opt-in. |
| Framework lint | Every plugin for each framework in use (React, Next, Django, FastAPI, Ansible, Docker, GitHub Actions, ...), including accessibility rules for UI. |
| Formatting | One formatter, checked in CI and applied by hooks; `.editorconfig` for everything else. |
| Architecture | Layer and boundary rules checked by a tool, plus tests that encode the structure as an allow-list (see [architecture and tests](references/architecture-and-tests.md)). |
| Dependencies | Unused, missing and misplaced dependencies; lockfile in sync; cycles banned. |
| Security | Secret scanning, dependency vulnerabilities, static analysis of code, CI workflows and containers, all pinned and scheduled (see [CI and supply chain](references/ci-and-supply-chain.md)). |
| Tests | A pyramid with a coverage floor per layer, branch coverage, warnings as errors, strict markers, no skipped tests without an issue link. |
| Docs for agents | `AGENTS.md` at the root listing the commands and rules. No `CLAUDE.md`: Claude Code reads `AGENTS.md` directly (v2.1.277+), and any `CLAUDE.md` in or above the working directory makes it ignore `AGENTS.md` unless that file imports it. |

## Default frameworks

- **Websites:** Astro with TypeScript, see [Astro](references/astro.md).
- **MCP servers:** FastMCP in Python, see [FastMCP](references/fastmcp.md).

Use these unless the repo already uses something else or the request names an
alternative. If a requirement does not fit, say why before choosing another
framework.

Stack specifics: [TypeScript and React](references/typescript.md),
[Python](references/python.md). For any other stack, find the equivalent of
each row (for example `golangci-lint` with most linters enabled, `clippy` with
`-D warnings` and `clippy::pedantic`, `ArchUnit` for the JVM, `NetArchTest` for
.NET) and record what you chose and why in the repo's `AGENTS.md`.

## Wiring

1. **One command runs every gate**: `make check` (or the stack's equivalent),
   which is the default target. It runs exactly what CI runs, through the same
   invocations, so a green local run predicts a green CI run. Slow or
   environment-hungry suites, such as browser end-to-end tests, get their own
   target and CI job and are named in `AGENTS.md`.
2. **Pre-commit hooks mirror CI.** Use the `pre-commit` framework (or
   `lefthook` in a JS repo). Fast gates run on commit, slow ones on push. Tools
   that the project already pins run as `local` hooks through the project's
   own runner, so hook versions cannot drift from lockfile versions.
3. **CI runs every gate as a separate job**, on pull requests, on pushes to the
   default branch and on a daily schedule so new advisories surface without a
   push. A final aggregate job named `ci` depends on all the others and passes
   only if each succeeded or was skipped; branch protection requires only that
   one check, so adding a job never means editing the rules.
4. **Pin everything.** Dependencies and tool versions exact or locked, GitHub
   Actions by commit SHA with the version in a comment, container images by
   digest where practical. Dependabot (or Renovate) keeps the pins moving, with
   a cooldown for brand-new releases.
5. **Create the repo with the gates on from the first commit**, when they cost
   nothing. In an existing repo, see below.

## Scaffolding a new repo

1. Ask only what the code cannot tell you: language and framework, whether it
   is a library, service, UI or CLI, and whether it will have several bounded
   contexts. Otherwise choose and state the default.
2. Write the gate configuration and a trivial passing example in each test
   layer *first*, then the first real code. The first commit must pass
   `make check`.
3. Add `.editorconfig`, `.gitignore`, `.pre-commit-config.yaml`,
   `dependabot.yml`, the CI workflow, `AGENTS.md` and, for containerised work,
   a devcontainer.
4. Install the hooks (`make install`) and run `make check` from a clean clone
   before finishing.

## Hardening an existing repo

1. **Audit first.** Produce a table of each gate row above as present, partial
   or missing, with the file that evidences it. Do not start editing until the
   table is written.
2. **Add one gate per commit**, cheapest and highest value first: formatter,
   secret scanning, workflow linting, lockfile check, dependency audit, strict
   typing, lint, tests and coverage, architecture rules.
3. **Never leave `main` red or switch a gate off to land it.** When a gate
   would fail on existing code, record a baseline (a ruff `per-file-ignores`
   block, mypy `[[overrides]]` per module, an ESLint bulk suppressions file,
   coverage `fail_under` at today's value) and make it ratchet: the baseline
   may shrink but a check must fail if it grows.
4. Open a tracking issue listing what remains in each baseline.

## Every gate must be proven to bite

A gate that cannot fail is decoration. After adding one, introduce a deliberate
violation, confirm the command fails for the right reason, and revert it.
Architecture rules deserve a committed test: a fixture that violates the rule
and an assertion that the checker rejects it.

## Rules for suppressions

- Fix the cause before suppressing. When a suppression stays, it names the rule
  (`# noqa: S101`, `// eslint-disable-next-line rule-name`, never a bare ignore)
  and carries a comment saying *why*.
- Prefer a per-file or per-directory rule in config, with the reason, over
  scattered inline comments.
- Enable the checker's "unused suppression" option (`ruff` `RUF100`, mypy
  `warn_unused_ignores`, ESLint `reportUnusedDisableDirectives`) so stale ones
  fail.

## Done means

`make check` passes from a fresh clone; CI is green, including the aggregate
`ci` job; every gate has been shown to fail on a deliberate violation; and
`AGENTS.md` tells the next contributor, human or agent, every command and rule
they need.

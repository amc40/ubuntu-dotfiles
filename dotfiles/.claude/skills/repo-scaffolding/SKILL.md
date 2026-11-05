---
name: repo-scaffolding
description: Set up a new repository, or audit and harden an existing one, around the owner's preference for as many automated quality gates as practical - strict typing, language and framework linting, formatting, enforced architecture (DDD), security checks, and layered test coverage. Use when asked to scaffold, bootstrap or initialise a repo or project, add tooling or CI to one, or check which quality gates are missing.
---

# Repo scaffolding preferences

Maximise **automated** quality gates, so review spends its time on design
rather than on style, types or missing tests. A rule that lives only in a
document or in someone's head is not a gate.

These are principles, not a toolchain. Pick the strictest, best-supported tool
for the ecosystem and record the choice in `AGENTS.md`; don't ask which to use.
The owner will standardise on specific tools when they want to.

## Gates

- **Typing:** the strictest mode available, plus the extra checks strict mode
  leaves off. Validate data at system boundaries.
- **Linting:** the language's full rule set, minus only rules that conflict
  with the formatter or each other, so new rules are opt-out. Add framework-
  specific linting too (for example React as well as TypeScript), including
  accessibility for UI.
- **Formatting:** one formatter, checked in CI and applied by hooks.
- **Architecture:** enforce structure with a tool, not convention. Use
  domain-driven design: bounded contexts, layered inwards-only dependencies,
  a pure domain with no framework or I/O imports, access to other contexts
  only through their public interface, no import cycles.
- **Dependencies:** unused, missing and misplaced dependencies flagged; lockfile
  kept in sync.
- **Security:** secret scanning, known-vulnerable dependencies, static analysis
  of code, CI workflows and containers, all on a schedule as well as on change.
- **Tests:** cover every layer of the pyramid (unit, integration, contract,
  end to end) with branch coverage and a separate floor per layer. Coverage must
  come from the right layer, new code must be covered on pull requests, warnings
  are errors, and skipped tests need a reason. Check test quality (mutation or
  property testing) where it is worth the cost.
- **Agent docs:** `AGENTS.md` at the root listing the commands and rules. No
  `CLAUDE.md`: Claude Code reads `AGENTS.md` directly, and a `CLAUDE.md` in or
  above the working directory makes it ignore `AGENTS.md` unless that file
  imports it.

## Default frameworks

Websites use Astro. MCP servers use FastMCP in Python. Use something else only
if the repo already does or the request says so.

## Wiring

- **One command runs every gate** (`make check` or the stack's equivalent), and
  it runs exactly what CI runs.
- **Pre-commit hooks mirror CI:** fast gates on commit, slow ones on push.
- **CI runs each gate as its own job**, on pull requests, on the default branch
  and on a daily schedule. One aggregate job depends on all the others and is
  the only required check, so adding a job never means editing branch rules.
- **Pin everything:** dependencies, tools, CI actions (by commit hash) and
  hook versions, with automated updates.
- Gates are on from the first commit, which must pass them.

## Existing repos

Audit first: list each gate as present, partial or missing, with evidence, and
write that down before editing. Then add one gate per commit, cheapest and
highest value first. Never leave the default branch red or switch a gate off to
land it: record a baseline of existing violations that may shrink but must not
grow, and track what remains in an issue.

## Prove each gate bites

After adding a gate, introduce a deliberate violation, confirm it fails for the
right reason, and revert it. Commit a test for architecture rules.

## Suppressions

Fix the cause first. A suppression that stays names the specific rule and says
why, and unused suppressions fail the build.

## Done

The one command passes from a fresh clone, CI is green including the aggregate
job, every gate has been shown to fail on a violation, and `AGENTS.md` tells the
next contributor, human or agent, every command and rule they need.

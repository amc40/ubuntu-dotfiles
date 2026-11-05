# Python

Manage with `uv`: a committed `uv.lock`, `uv sync --all-groups`, and
`uv run --frozen` everywhere. A single `pyproject.toml` at the workspace root
holds the one configuration for every package.

## Typing

`mypy` with `strict = true` plus `warn_unreachable` and the extra error codes
`explicit-override`, `ignore-without-code`, `possibly-undefined`,
`redundant-expr`, `truthy-bool` and `unused-awaitable`. Add `types-*` stubs
rather than ignoring imports. Validate boundaries with `pydantic` or
`msgspec`. Every module starts with `from __future__ import annotations`
(enforced by ruff's isort `required-imports`).

## Lint and format

`ruff` with `select = ["ALL"]` and an `ignore` list holding only the rules that
conflict with the formatter or each other (`COM812`, `ISC001`, `D203`, `D213`),
each with a comment. Google docstring convention. `ban-relative-imports = "all"`
and `flake8-tidy-imports.banned-api` for APIs that must stay behind a wrapper.
Tests get a small, commented `per-file-ignores` block (`S101`, `PLR2004`,
`SLF001`, `D103`). Framework rules come from ruff's `DJ`, `FAST`, `AIR`, `NPY`
and `PD` sets, all included by `ALL`. `ruff format` is the formatter.

## Dependencies and security

- `deptry` for unused, missing, transitive and misplaced dependencies, run
  once per workspace member.
- `uv lock --check` for lockfile freshness.
- `pip-audit` against `uv export --frozen --all-groups --no-emit-workspace`, so
  it audits exactly what `uv sync` installs.
- Bandit's rules via ruff `S`; `semgrep` in CI.

## Architecture

`import-linter` contracts in `pyproject.toml` for the layering and context
independence described in [architecture and tests](architecture-and-tests.md),
plus allow-list tests for rules a contract cannot express.

## Tests

`pytest` with `--cov`, `branch = true`, `fail_under = 100` where practical, and
these options: `--strict-config`, `--strict-markers`, `--import-mode=importlib`,
`filterwarnings = ["error"]`, `xfail_strict = true`. Slow or environment-hungry
tests carry a marker (`browser`, `integration`) excluded from the default run
and run by their own target and CI job; those runs use `--no-cov` so they
cannot be used to meet the floor. `pytest-asyncio` in auto mode for async code,
`hypothesis` for properties, `mutmut` nightly on `domain`.

## Targets

`make install` (sync and hooks), `format`, `lint`, `types`, `deps`, `audit`,
`test` and `check`, with `check` running everything CI runs.

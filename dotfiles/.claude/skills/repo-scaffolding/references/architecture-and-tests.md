# Architecture enforcement and the testing pyramid

## Structure for domain-driven design

- Each **bounded context** is a top-level module (`src/billing`, `src/catalog`)
  with `domain`, `application` and `infrastructure` layers, and `ui` or `api`
  where the context has one.
- Dependencies point inwards only: `ui/api` and `infrastructure` may import
  `application` and `domain`; `application` may import `domain`; `domain`
  imports nothing outside itself and the standard library. No framework, ORM,
  HTTP client or logger in `domain`.
- A context reaches another only through its public entry point (`index.ts`,
  `__init__.py` or a `public` module), never its internals. Cross-context
  coupling goes through ids, events or an anti-corruption layer in
  `infrastructure`.
- No import cycles anywhere.

## Enforce it with a tool, not a convention

| Stack | Tool |
| --- | --- |
| TypeScript | `dependency-cruiser` for layers, cycles, orphans and forbidden dependencies; `eslint-plugin-boundaries` or Nx `enforce-module-boundaries` for editor feedback. |
| Python | `import-linter` contracts (`layers`, `independence`, `forbidden`) or `tach`; ruff `TID251` bans individual APIs. |
| JVM | `ArchUnit`. |
| .NET | `NetArchTest` or `ArchUnitNET`. |

Start from a deny-by-default rule set and make exceptions explicit and
commented. Run the tool in `make check` and CI.

## Structure as an allow-list test

Where a rule is "only these modules may do X", write it as an allow-list test
that scans every package, so a new package is covered without anyone
registering it and a new exception needs a reason in the diff. Keep the list
short and put the reason next to each entry. Where a linter and a test express
the same rule, add a test that asserts the two lists agree.

## Testing pyramid

| Layer | Scope | Doubles | Speed | Share |
| --- | --- | --- | --- | --- |
| Unit | One function, class or aggregate in `domain` and `application` | None in `domain`; fakes for ports in `application` | Milliseconds | Most tests |
| Integration | An adapter against the real thing: database, queue, filesystem, HTTP via a recorded or containerised service | Real infrastructure, faked network edges | Seconds | Each adapter and each port contract |
| Contract | A consumer and a provider agree on an API or event schema | Pact, schema or OpenAPI checks | Seconds | One per boundary |
| End to end | A few critical user journeys through the deployed shape | None | Minutes | Smoke and critical paths only |

Keep layers in separate directories or markers with their own commands and CI
jobs (`test:unit`, `test:integration`, `test:e2e`), so a slow layer never hides
a fast one.

### Coverage that proves the pyramid

- **Branch coverage on, with a floor per layer.** Defaults: `domain` 100%,
  `application` 95%, adapters 80% from integration tests, UI components 80%.
  Where the repo is small enough, a flat 100% is better. Configure per-path
  thresholds (Vitest `coverage.thresholds` with glob keys; `coverage.py`
  `fail_under` per run).
- **Coverage from the right layer.** Domain coverage must come from unit tests,
  not from end-to-end runs that happen to touch it. Run each layer with its own
  coverage report and floor, and do not merge reports to meet a threshold.
- **Diff coverage on pull requests**: new and changed lines at 100% or a
  stated threshold, via `diff-cover` or the coverage service's patch check.
- **Every adapter has an integration test and every boundary has a contract
  test.** A small script in `make check` that fails when a `infrastructure`
  module has no matching integration test is worth its few lines.
- **Mutation testing** (`Stryker`, `mutmut` or `cosmic-ray`) on `domain` and
  `application`, run nightly, with a minimum score. Coverage says code ran;
  mutation testing says the tests would notice if it were wrong.
- Warnings are errors in tests, markers and configuration are strict, and a
  skipped or expected-fail test needs an issue link (`xfail_strict`,
  `--forbid-only`, `eslint-plugin-vitest/no-disabled-tests`).
- Property-based tests (`hypothesis`, `fast-check`) for parsers, serialisers and
  invariants in `domain`.

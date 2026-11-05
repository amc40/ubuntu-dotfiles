# TypeScript and React

Choices are the strictest that the ecosystem supports; prefer ESLint with
Prettier over Biome because the framework and type-aware plugins matter more
than speed. Pin exact versions with a lockfile, install with `npm ci` or
`pnpm install --frozen-lockfile`.

## Typing

`tsconfig.json` with `"strict": true` and also `noUncheckedIndexedAccess`,
`exactOptionalPropertyTypes`, `noImplicitOverride`,
`noPropertyAccessFromIndexSignature`, `noFallthroughCasesInSwitch`,
`noUnusedLocals`, `noUnusedParameters`, `verbatimModuleSyntax`,
`isolatedModules` and `forceConsistentCasingInFileNames`. `tsc --noEmit` in
`make check`. Validate every boundary (HTTP, storage, env, `JSON.parse`) with
a schema library such as `zod`, deriving the type from the schema, and add
`type-coverage` with an `--at-least` floor to catch creeping `any`.

## Lint (ESLint flat config)

- `typescript-eslint`: `strictTypeChecked` and `stylisticTypeChecked` with
  `parserOptions.projectService: true`; `no-explicit-any`,
  `no-floating-promises`, `consistent-type-imports` and `ban-ts-comment` as
  errors (with `allow-with-description`).
- `eslint-plugin-react`, `eslint-plugin-react-hooks`, `eslint-plugin-jsx-a11y`
  (strict preset), `eslint-plugin-react-refresh` for Vite or
  `@next/eslint-plugin-next` for Next.
- `eslint-plugin-import-x` with `no-cycle`, `no-self-import` and
  `no-extraneous-dependencies`; `eslint-plugin-unicorn`; `eslint-plugin-sonarjs`;
  `eslint-plugin-security` for the cheap first pass.
- `eslint-plugin-vitest` (or `-jest`) and `eslint-plugin-testing-library` for
  tests, `eslint-plugin-playwright` for end-to-end.
- `eslint-config-prettier` last, so formatting is never lint's job.
- `linterOptions.reportUnusedDisableDirectives: "error"`, and
  `eslint --max-warnings 0`.

## Formatting

Prettier, `prettier --check .` in CI, `.editorconfig` alongside it.

## Structure and dependencies

- `dependency-cruiser` for layer rules, cycles and orphans; `eslint-plugin-boundaries`
  for the same rules in the editor.
- `knip` for unused files, exports and dependencies.
- `publint` and `@arethetypeswrong/cli` for libraries.

## Tests

- `vitest` with `@vitest/coverage-v8`, branch coverage, per-glob thresholds.
- Component tests with Testing Library and `user-event`; network faked at the
  edge with `msw`.
- Integration tests with real adapters (Testcontainers for databases).
- `playwright` for end-to-end journeys, with `@axe-core/playwright` for
  accessibility checks on each journey.
- `fast-check` for properties; `@stryker-mutator/core` nightly on `domain`.

## Scripts

`package.json` exposes `format`, `lint`, `types`, `deps` (knip and
dependency-cruiser), `test:unit`, `test:integration`, `test:e2e`, `audit` and
`check`, with the Makefile calling these so the entry point is the same in
every language.

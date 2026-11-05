# Astro (websites)

Astro is the default for websites. Use TypeScript throughout and follow
[TypeScript and React](typescript.md) for everything not specific to Astro
(tsconfig flags, ESLint base, Prettier, Vitest, Playwright). Pin exact versions
of `astro` and every `@astrojs/*` integration; they move together.

## Typing

- `tsconfig.json` extends `astro/tsconfigs/strictest`, with the extra flags
  listed in the TypeScript reference layered on top.
- `astro check` (needs `@astrojs/check` and `typescript`) type-checks `.astro`
  files, content collections and frontmatter. It runs in `make check` next to
  `tsc --noEmit`, because `tsc` alone cannot see `.astro` files.
- Content is typed at the source: every content collection has a Zod schema in
  `src/content.config.ts`, and pages read collections through
  `getCollection` and `getEntry`, never from raw files. Environment variables go
  through `astro:env` with a schema.

## Lint and format

- `eslint-plugin-astro` with its `recommended` preset, and its `jsx-a11y-strict`
  preset for accessibility in `.astro` templates; the base TypeScript rules
  from the TypeScript reference for `.ts` and framework islands.
- `prettier` with `prettier-plugin-astro`.
- Island components (React, Svelte and so on) get that framework's own lint
  plugins.

## Structure

- `src/pages` stays thin: routing, data loading and composition only. Logic
  lives in `src/lib` (pure TypeScript, no Astro imports), components in
  `src/components`, layouts in `src/layouts`.
- `dependency-cruiser` rules: `src/lib` imports nothing from `src/pages`,
  `src/components` or `src/layouts`; components do not import pages; no cycles.
- Ship JavaScript only by decision: `client:*` directives are needed only for
  real interactivity, and each one is a commented exception. Prefer
  `client:visible` or `client:idle` to `client:load`.

## Output quality gates

Run against the built site (`astro build`, then `astro preview`):

| Gate | Tool |
| --- | --- |
| Build succeeds with no warnings | `astro build`, with warnings treated as failures in CI |
| Valid HTML | `html-validate` on `dist/` |
| No broken links or anchors | `linkinator` or an equivalent crawler against the preview server |
| Accessibility | `@axe-core/playwright` on every page template |
| Performance, SEO and best practice budgets | Lighthouse CI with asserted minimum scores and size budgets |
| Image and asset hygiene | `astro:assets` for images, with an assertion that `alt` is present (covered by `jsx-a11y`) |

## Security

- Security headers (`Content-Security-Policy`, `Strict-Transport-Security`,
  `X-Content-Type-Options`, `Referrer-Policy`, `Permissions-Policy`) are set at
  the host or adapter, and a Playwright test asserts them on the preview.
- Never `set:html` untrusted input; an ESLint `no-restricted-syntax` rule or a
  `semgrep` rule flags `set:html` so each use needs a justification.
- Third-party scripts are listed, pinned and loaded with Subresource
  Integrity where the provider allows it.
- `npm audit` and `gitleaks` as in [CI and supply chain](ci-and-supply-chain.md);
  the deploy job runs only after `ci` passes.

## Tests

- **Unit:** Vitest, using `getViteConfig` from `astro/config`, for `src/lib` and
  content schemas, with a coverage floor on `src/lib`.
- **Component:** Astro's Container API renders `.astro` components to strings
  for assertions; Testing Library covers interactive islands.
- **End to end:** Playwright against `astro preview`, one journey per important
  page type, each with an axe scan. Visual regression snapshots only for
  design-system components.

## Targets

`make check` runs `format`, `lint`, `types` (`astro check` and `tsc`), `deps`,
`test:unit`, `build`, `test:e2e` against the preview, and `audit`.

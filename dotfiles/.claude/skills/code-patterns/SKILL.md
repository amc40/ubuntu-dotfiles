---
name: code-patterns
description: The owner's preferences for how code is structured, kept as one pattern per file with machine-checkable front matter. Use before writing or changing code, to follow the preferences that apply, and when reviewing code adversarially, to check a diff against them as a rubric. Not for repository tooling or quality gates (use repo-scaffolding).
---

# Code patterns

Each preference is a file in `patterns/`. One file per pattern, so a use of
the skill loads only the patterns that apply.

## Find the patterns that apply

List `patterns/*.md` and read only the front matter of each. `applies_when`
says what kind of code the pattern is about. Open the full file only for
patterns that match what you are writing or reviewing. The set of patterns is
the directory listing; there is no separate index to keep in step.

## Writing code

Follow the `principle` and the "Prefer" guidance in the body of every
pattern that applies. If a pattern cannot be followed, say why in the change
rather than quietly deviating.

## Reviewing code

Treat the front matter as a rubric and read the diff looking for violations,
not for confirmation:

- `smells` are the signals that a violation is present. Hunt for them, and try
  to construct a path through the code where the pattern's principle fails.
- `not_a_violation` lists cases to leave alone. Check a finding against it
  before reporting.
- `finding_format` says what a useful finding recommends. Report the
  `file:line`, the smell that matched and that recommendation.

Report a verdict per applicable pattern, and name the patterns you judged
not to apply so "no findings" can be told apart from "not checked".

## Adding or changing a pattern

The front matter must satisfy [the schema](references/pattern.schema.json),
and `name` must equal the filename without `.md`. `test/consistency.sh`
checks both. The body is free-form and is for the author's benefit: put the
preferred shape and a short example there.

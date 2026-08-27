# Coding agent instructions

## High Level Approach
1. Follow a TDD approach: decide how to validate a change before implementing it.
2. For involved changes, outline the planned commits and validation steps before committing.

## Code
1. Add comments only when they explain **why**, not **what**.
2. Skip linting rules only after considering alternatives, and explain why in a comment.

## Dependencies
1. Before adding a dependency, consider alternatives, typed interfaces, maintenance status, and documentation quality.
2. Pin dependency versions wherever possible.

## PRs
1. After raising a PR, ensure checks pass and investigate failures with `gh run view`.
2. PRs should link to any GitHub issues they address.
3. Before raising a PR, run an available code review workflow if one has not been run recently.

## Shell/Bash commands
1. Prefer composed tools over custom scripts or complex arguments.
2. For data formats, prefer purpose-built tools such as `jq` and `yq`.

## Investigation
1. Include references in findings and double-check them.

## Git
1. When changing an existing commit, make a `--fixup` commit so it can be autosquashed.
2. Before changing files outside a worktree, ask whether to create one.
3. Do not use `cd` and `git` in the same shell invocation.

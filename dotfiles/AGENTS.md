# Coding agent instructions

## High Level Approach
1. Follow a TDD approach: decide how to validate a change before implementing it.
2. For involved changes, outline the planned commits and validation steps before committing.

## Code
1. Add comments only when they explain **why**, not **what**.
2. Skip linting rules only after considering alternatives, and explain why in a comment.
3. Before writing or changing code, follow the `code-patterns` skill for every pattern whose `applies_when` matches.

## Dependencies
1. Before adding a dependency, consider alternatives, typed interfaces, maintenance status, and documentation quality.
2. Pin dependency versions wherever possible.

## PRs
1. After raising a PR, ensure checks pass and investigate failures with `gh run view`.
2. PRs should link to any GitHub issues they address.
3. Before raising a PR, run an available code review workflow if one has not been run recently, and a `pattern-reviewer` subagent pass where available.
4. Commit fixes for review findings as `--fixup` commits, then autosquash them (`GIT_SEQUENCE_EDITOR=true git rebase -i --autosquash <base>`) and update the branch with `git push --force-with-lease`.
5. After autosquashing, delegate a quick check to a subagent (`commit-message-checker` where available) that each commit message and the PR description accurately describe what that commit or PR actually changes, and fix any mismatch by rewording.

## Shell/Bash commands
1. Prefer composed tools over custom scripts or complex arguments.
2. Before choosing, installing or invoking a tool, follow the `tooling-preferences` skill.

## Investigation
1. Include references in findings and double-check them.

## Git
1. When changing an existing commit, make a `--fixup` commit so it can be autosquashed.
2. Before changing files outside a worktree, ask whether to create one.
3. Do not use `cd` and `git` in the same shell invocation.

---
name: tooling-preferences
description: The owner's chosen tools for package management, running scripts and one-off CLIs, and handling data formats. Use before picking, installing or invoking a tool, adding a dependency manager or CI install step, or writing a command that parses or edits JSON or YAML. Not for which quality gates a repository should have (use repo-scaffolding) or how code is structured (use code-patterns).
---

# Tooling preferences

Where this skill names a tool, use it without asking and without offering
alternatives. Where it is silent, pick the best-supported tool for the
ecosystem and say which you chose so the owner can add it here.

## Python

Use `uv` for everything: environments, dependencies and running scripts. For a
one-off tool, run it with `uvx <tool>@<version>` rather than installing it, and
pin the version. Do not use `pip`, `pipx`, `poetry` or hand-made virtualenvs.

In CI, install `uv` with the `astral-sh/setup-uv` action, pinned to a commit.

## Data formats

Parse and edit JSON with `jq` and YAML with `yq`, not with `grep`, `sed` or
ad-hoc scripts. Prefer the purpose-built tool over a custom script for any
other structured format too.

## Adding a preference

Add the tool under the ecosystem or task it covers, with one line on what it
replaces. Keep this file to choices the owner has made; do not record a guess
as a preference.

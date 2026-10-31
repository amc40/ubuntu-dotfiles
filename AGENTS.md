# Repository instructions

## Development Commands

```bash
make test
make sync
make release VERSION=x.y.z
```

## Project Overview

This repository packages Ubuntu dotfiles as standalone dotfiles, a Docker image, and a devcontainer feature. All three use the same underlying dotfiles and installation script.

## Architecture

The `/dotfiles/` directory is the source of truth:
- `install.sh` installs zsh, oh-my-zsh, an optional coding agent, and configuration files.
- `.claude/` contains Claude Code settings and an instruction entry point.
- `.codex/` contains Codex global instructions and configuration.

The devcontainer feature is defined in `/devcontainer-feature/src/ubuntu-dotfiles/`. Its `install.sh` extracts the dotfiles archive and invokes the shared installer.

## Testing

Run `make test`. It tests the devcontainer feature on Ubuntu 22.04 and the latest Ubuntu release.

## Adding or Removing a Component

`KNOWN_COMPONENTS` in `dotfiles/install.sh` is the source of truth. When changing it, also update:
- an `install_<name>` function in `dotfiles/install.sh`
- the component and option tables in `README.md`
- for non-agent components, a boolean option in `devcontainer-feature/src/ubuntu-dotfiles/devcontainer-feature.json`, its `--skip` line in the feature's `install.sh`, and a scenario in `devcontainer-feature/test/ubuntu-dotfiles/scenarios.json` that disables it

`test/consistency.sh` (run by `make test` and CI) fails until these agree. Do not name an option `zsh` or `tmux`: devcontainer exposes options as environment variables and these clash with oh-my-zsh and tmux.

## Release Process

Run `make release VERSION=1.2.3`. This updates the feature version, creates and pushes a semver tag, and triggers GitHub Actions to test and publish the Docker image and devcontainer feature.

## Architectural Decisions

See [DECISIONS.md](./DECISIONS.md) for the feature artifact strategy.

## Guidelines

@dotfiles/AGENTS.md

## Git

1. Do not use `--fixup` commits in this repository.

# ubuntu-dotfiles

Repository that sets up common config files in my home directory (dotfiles) for an Ubuntu machine.

Run `./install.sh` to run the setup. Setup steps should be idempotent.

## Choosing what to install

`install.sh` is split into components: `zsh`, `tmux`, `claude`, `codex` and `repo` (clones this repo to `~/ubuntu-dotfiles`). With no arguments it installs everything except the agent you didn't pick via `AGENT` (`claude` by default, or `codex`/`none`).

```bash
./install.sh --only claude        # just the Claude Code config
./install.sh --only claude,tmux
./install.sh --skip zsh,repo      # defaults minus these
```

`--only` and `--skip` can't be combined. Claude config is merged into any existing `~/.claude/settings.json` (permission lists are unioned) and an existing `~/.claude.json` is left alone, so it is safe to run inside a session that already has its own state.

## Claude cloud sessions

Cloud sessions don't run `install.sh`, so `~/.claude` is the default one. To get this config in every session, add this to the environment's setup script (environment menu in the session title bar, then Edit):

```bash
git clone --depth 1 https://github.com/amc40/ubuntu-dotfiles.git /tmp/ubuntu-dotfiles
/tmp/ubuntu-dotfiles/dotfiles/install.sh --only claude
```

This repo must be reachable from the environment.

## Devcontainer feature

The feature installs Claude Code by default. Select Codex or skip coding-agent installation with its `agent` option:

```json
{
  "features": {
    "ghcr.io/amc40/ubuntu-dotfiles:latest": {
      "agent": "codex"
    }
  }
}
```

Each part can be turned off. These options map to the `install.sh` components above:

| Option | Default | Component |
| --- | --- | --- |
| `agent` | `claude` | `claude`, `codex`, or `none` |
| `installZsh` | `true` | `zsh` |
| `installTmux` | `true` | `tmux` |
| `cloneRepo` | `true` | `repo` (also adds it to the VS Code workspace) |

For example, just the Claude config:

```json
{
  "features": {
    "ghcr.io/amc40/ubuntu-dotfiles:latest": {
      "installZsh": false,
      "installTmux": false,
      "cloneRepo": false
    }
  }
}
```

## Docker

A pre-built Docker image is published to the GitHub Container Registry:

```bash
docker pull ghcr.io/amc40/ubuntu-dotfiles:latest
```

You can also specify a version:

```bash
docker pull ghcr.io/amc40/ubuntu-dotfiles:1.0.0
```

To build locally:

```bash
docker build -t ubuntu-dotfiles .
# With a specific Ubuntu version:
docker build --build-arg UBUNTU_VERSION=24.04 -t ubuntu-dotfiles .
# With a custom username:
docker build --build-arg USERNAME=myuser -t ubuntu-dotfiles .
```

### Publishing a new release

Images are published automatically when a semver tag is pushed:

```bash
git tag v1.0.0
git push origin v1.0.0
```

This publishes the following tags to `ghcr.io/amc40/ubuntu-dotfiles`:
- `1.0.0` — exact version
- `1.0` — minor float
- `1` — major float

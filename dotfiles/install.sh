#!/bin/bash
set -euxo pipefail

USERNAME="${USERNAME:-$(whoami)}"
USER_HOME="${USER_HOME:-$HOME}"
DOTFILES_PATH="${DOTFILES_PATH:-$(cd "$(dirname "$0")" && pwd)}"
AGENT="${AGENT:-claude}"

KNOWN_COMPONENTS="zsh tmux claude codex repo"

usage() {
    cat <<EOF
Usage: install.sh [--only COMPONENTS | --skip COMPONENTS]

COMPONENTS is a comma-separated list from: ${KNOWN_COMPONENTS// /, }.

With no arguments, installs zsh, tmux, the agent selected by \$AGENT
(claude, codex or none; default claude) and clones the dotfiles repo.

  --only   install just these components
  --skip   install the defaults minus these components
EOF
}

if [ "$AGENT" != "claude" ] && [ "$AGENT" != "codex" ] && [ "$AGENT" != "none" ]; then
    echo "AGENT must be one of: claude, codex, none" >&2
    exit 1
fi

default_components="zsh tmux repo"
if [ "$AGENT" != "none" ]; then
    default_components="zsh tmux $AGENT repo"
fi

only=""
skip=""
while [ $# -gt 0 ]; do
    case "$1" in
        --only) only="${2:?--only needs a value}"; shift 2 ;;
        --skip) skip="${2:?--skip needs a value}"; shift 2 ;;
        -h|--help) usage; exit 0 ;;
        *) echo "Unknown argument: $1" >&2; usage >&2; exit 1 ;;
    esac
done

if [ -n "$only" ] && [ -n "$skip" ]; then
    echo "--only and --skip cannot be combined" >&2
    exit 1
fi

validate_components() {
    local name
    for name in ${1//,/ }; do
        case " $KNOWN_COMPONENTS " in
            *" $name "*) ;;
            *) echo "Unknown component: $name (known: $KNOWN_COMPONENTS)" >&2; exit 1 ;;
        esac
    done
}

validate_components "$only"
validate_components "$skip"

if [ -n "$only" ]; then
    components="${only//,/ }"
else
    components=""
    for name in $default_components; do
        case ",$skip," in
            *",$name,"*) ;;
            *) components="$components $name" ;;
        esac
    done
fi

wants() {
    case " $components " in
        *" $1 "*) return 0 ;;
        *) return 1 ;;
    esac
}

## HELPERS

# Cloud containers run as root without sudo installed, so only use sudo when needed.
as_root() {
    if [ "$(id -u)" -eq 0 ]; then
        "$@"
    else
        sudo "$@"
    fi
}

run_as_user() {
    if [ "$(id -un)" = "$USERNAME" ]; then
        sh -c "$1"
    else
        su "$USERNAME" -c "$1"
    fi
}

own() {
    if [ "$(id -un)" != "$USERNAME" ]; then
        as_root chown -R "$USERNAME:$USERNAME" "$@"
    fi
}

# Skips apt entirely when everything is already installed, which keeps
# component-only runs fast and usable without network access to apt mirrors.
ensure_packages() {
    local missing=""
    local package
    for package in "$@"; do
        dpkg -s "$package" &> /dev/null || missing="$missing $package"
    done
    if [ -n "$missing" ]; then
        as_root apt-get update
        # shellcheck disable=SC2086 # word splitting of the package list is intended
        as_root apt-get install -y $missing
    fi
}

## OH MY ZSH

install_zsh() {
    ensure_packages zsh wget git

    if [ ! -d "$USER_HOME/.oh-my-zsh" ]; then
        echo "Installing oh-my-zsh"
        run_as_user 'CHSH=no KEEP_ZSHRC=yes RUNZSH=no sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"'
    fi

    cp "$DOTFILES_PATH/.zshrc" "$USER_HOME/.zshrc"
    own "$USER_HOME/.zshrc"

    as_root usermod -s "$(which zsh)" "$USERNAME"
}

## CODING AGENTS

# Merges rather than overwrites so that settings already present (for example
# hooks configured by a cloud environment) survive. Permission lists are
# unioned; for any other conflicting key the dotfiles value wins.
install_claude_settings() {
    local source="$DOTFILES_PATH/.claude/settings.json"
    local dest="$USER_HOME/.claude/settings.json"

    ensure_packages jq
    # Always going through jq keeps the output byte-identical between the first
    # run and re-runs.
    local existing='{}'
    if [ -f "$dest" ]; then
        existing="$(cat "$dest")"
    fi
    local merged
    merged="$(mktemp)"
    jq -s '
        (.[0].permissions.allow // []) as $a0 | (.[1].permissions.allow // []) as $a1 |
        (.[0].permissions.deny // []) as $d0 | (.[1].permissions.deny // []) as $d1 |
        (.[0] * .[1])
        | .permissions.allow = ($a0 + $a1 | unique)
        | .permissions.deny = ($d0 + $d1 | unique)
    ' <(echo "$existing") "$source" > "$merged"
    mv "$merged" "$dest"
}

install_claude() {
    if ! command -v claude &> /dev/null; then
        ensure_packages curl
        echo "Installing Claude Code"
        run_as_user "curl -fsSL https://claude.ai/install.sh | bash"
    fi

    mkdir -p "$USER_HOME/.claude"
    install_claude_settings
    cp "$DOTFILES_PATH/.claude/CLAUDE.md" "$USER_HOME/.claude/CLAUDE.md"
    cp "$DOTFILES_PATH/.claude/AGENTS.md" "$USER_HOME/.claude/AGENTS.md"

    # ~/.claude.json holds Claude Code's own state, so never replace an existing one.
    if [ ! -e "$USER_HOME/.claude/.claude.json" ]; then
        cp "$DOTFILES_PATH/.claude/.claude.json" "$USER_HOME/.claude/.claude.json"
    fi
    if [ ! -e "$USER_HOME/.claude.json" ]; then
        ln -s "$USER_HOME/.claude/.claude.json" "$USER_HOME/.claude.json"
    fi
    own "$USER_HOME/.claude"
}

install_codex() {
    if ! command -v codex &> /dev/null; then
        ensure_packages curl
        echo "Installing Codex"
        run_as_user "curl -fsSL https://chatgpt.com/codex/install.sh | sh"
    fi

    mkdir -p "$USER_HOME/.codex"
    cp "$DOTFILES_PATH/.codex/AGENTS.md" "$USER_HOME/.codex/AGENTS.md"
    cp "$DOTFILES_PATH/.codex/config.toml" "$USER_HOME/.codex/config.toml"
    own "$USER_HOME/.codex"
}

## TMUX

install_tmux() {
    ensure_packages tmux
    cp "$DOTFILES_PATH/.tmux.conf" "$USER_HOME/.tmux.conf"
    own "$USER_HOME/.tmux.conf"
}

## GIT

install_repo() {
    ensure_packages git
    local repo_path="$USER_HOME/ubuntu-dotfiles"
    if [ ! -d "$repo_path" ]; then
        run_as_user "git clone https://github.com/amc40/ubuntu-dotfiles.git '$repo_path'"
    fi
}

wants zsh && install_zsh
wants claude && install_claude
wants codex && install_codex
wants tmux && install_tmux
wants repo && install_repo
true

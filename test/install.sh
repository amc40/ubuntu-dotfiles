#!/bin/bash
# Runs dotfiles/install.sh against a throwaway HOME. Only covers components
# that need no package installs, so it is safe to run outside a container.
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
INSTALL="$REPO_ROOT/dotfiles/install.sh"
failures=0

check() {
    local description="$1"
    shift
    if "$@" >/dev/null 2>&1; then
        echo "PASS: $description"
    else
        echo "FAIL: $description"
        failures=$((failures + 1))
    fi
}

new_home() {
    HOME_DIR="$(mktemp -d)"
    # A stub keeps the installer from trying to download Claude Code.
    STUB_BIN="$(mktemp -d)"
    printf '#!/bin/sh\n' > "$STUB_BIN/claude"
    chmod +x "$STUB_BIN/claude"
}

run_install() {
    HOME="$HOME_DIR" USER_HOME="$HOME_DIR" PATH="$STUB_BIN:$PATH" "$INSTALL" "$@" >/dev/null 2>&1
}

# --only claude installs just the Claude config
new_home
check "--only claude succeeds" run_install --only claude
check "settings.json installed" test -f "$HOME_DIR/.claude/settings.json"
check "CLAUDE.md installed" test -f "$HOME_DIR/.claude/CLAUDE.md"
check "AGENTS.md installed" test -f "$HOME_DIR/.claude/AGENTS.md"
check ".zshrc not installed" test ! -e "$HOME_DIR/.zshrc"
check ".tmux.conf not installed" test ! -e "$HOME_DIR/.tmux.conf"
check "oh-my-zsh not installed" test ! -e "$HOME_DIR/.oh-my-zsh"
check "ubuntu-dotfiles repo not cloned" test ! -e "$HOME_DIR/ubuntu-dotfiles"

# Re-running changes nothing
before="$(find "$HOME_DIR" -type f -exec md5sum {} + | sort)"
run_install --only claude
after="$(find "$HOME_DIR" -type f -exec md5sum {} + | sort)"
check "re-run is idempotent" test "$before" = "$after"

# An existing ~/.claude.json holds session state and must survive
new_home
echo '{"existing":true}' > "$HOME_DIR/.claude.json"
run_install --only claude
check "existing ~/.claude.json preserved" grep -q '"existing":true' "$HOME_DIR/.claude.json"

# Existing settings are merged rather than replaced
new_home
mkdir -p "$HOME_DIR/.claude"
echo '{"hooks":{"x":1},"permissions":{"allow":["Bash(ls)"]}}' > "$HOME_DIR/.claude/settings.json"
run_install --only claude
check "existing settings keys kept" jq -e '.hooks.x == 1' "$HOME_DIR/.claude/settings.json"
check "existing permissions kept" jq -e '.permissions.allow | index("Bash(ls)")' "$HOME_DIR/.claude/settings.json"
check "dotfiles permissions added" jq -e '.permissions.allow | index("Bash(git * add *)")' "$HOME_DIR/.claude/settings.json"

# --skip removes a component from the defaults; --only claude,codex needs no agent clash
new_home
check "unknown component rejected" test "$(run_install --only bogus; echo $?)" != 0
check "--only and --skip together rejected" test "$(run_install --only claude --skip tmux; echo $?)" != 0

rm -rf "$HOME_DIR" "$STUB_BIN"

if [ "$failures" -ne 0 ]; then
    echo "$failures check(s) failed"
    exit 1
fi
echo "All checks passed"

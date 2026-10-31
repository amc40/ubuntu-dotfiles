#!/bin/bash
# Runs dotfiles/install.sh against a throwaway HOME. Only covers components
# that need no package installs, so it is safe to run outside a container.
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
INSTALL="$REPO_ROOT/dotfiles/install.sh"
failures=0
tmp_dirs=()
trap 'rm -rf "${tmp_dirs[@]}"' EXIT

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
    # Without a stub the installer would try to download Claude Code.
    STUB_BIN="$(mktemp -d)"
    tmp_dirs+=("$HOME_DIR" "$STUB_BIN")
    printf '#!/bin/sh\n' > "$STUB_BIN/claude"
    chmod +x "$STUB_BIN/claude"
}

run_install() {
    HOME="$HOME_DIR" USER_HOME="$HOME_DIR" PATH="$STUB_BIN:$PATH" "$INSTALL" "$@" >/dev/null 2>&1
}

new_home
check "--only claude succeeds" run_install --only claude
check "settings.json installed" test -f "$HOME_DIR/.claude/settings.json"
check "CLAUDE.md installed" test -f "$HOME_DIR/.claude/CLAUDE.md"
check "AGENTS.md installed" test -f "$HOME_DIR/.claude/AGENTS.md"
check ".zshrc not installed" test ! -e "$HOME_DIR/.zshrc"
check ".tmux.conf not installed" test ! -e "$HOME_DIR/.tmux.conf"
check "oh-my-zsh not installed" test ! -e "$HOME_DIR/.oh-my-zsh"
check "ubuntu-dotfiles repo not cloned" test ! -e "$HOME_DIR/ubuntu-dotfiles"

before="$(find "$HOME_DIR" -type f -exec md5sum {} + | sort)"
run_install --only claude
after="$(find "$HOME_DIR" -type f -exec md5sum {} + | sort)"
check "re-run is idempotent" test "$before" = "$after"

# Claude Code keeps session state in ~/.claude.json, so replacing it would lose that state.
new_home
echo '{"existing":true}' > "$HOME_DIR/.claude.json"
run_install --only claude
check "existing ~/.claude.json preserved" grep -q '"existing":true' "$HOME_DIR/.claude.json"

new_home
mkdir -p "$HOME_DIR/.claude"
echo '{"hooks":{"x":1},"permissions":{"allow":["Bash(ls)"]}}' > "$HOME_DIR/.claude/settings.json"
run_install --only claude
check "existing settings keys kept" jq -e '.hooks.x == 1' "$HOME_DIR/.claude/settings.json"
check "existing permissions kept" jq -e '.permissions.allow | index("Bash(ls)")' "$HOME_DIR/.claude/settings.json"
check "dotfiles permissions added" jq -e --slurpfile src "$REPO_ROOT/dotfiles/.claude/settings.json" '(.permissions.allow // []) as $got | $src[0].permissions.allow | all(. as $p | $got | index($p))' "$HOME_DIR/.claude/settings.json"

new_home
ln -s "$HOME_DIR/missing" "$HOME_DIR/.claude.json"
check "dangling ~/.claude.json symlink tolerated" run_install --only claude

new_home
mkdir -p "$HOME_DIR/.claude"
: > "$HOME_DIR/.claude/settings.json"
check "empty settings.json tolerated" run_install --only claude

# Skipping every other default component must leave exactly the Claude config.
new_home
run_install --skip zsh,tmux,repo
check "--skip leaves the Claude config" test -f "$HOME_DIR/.claude/settings.json"
check "--skip leaves out skipped components" test ! -e "$HOME_DIR/.tmux.conf"

new_home
check "unknown component rejected" test "$(run_install --only bogus; echo $?)" != 0
check "--only and --skip together rejected" test "$(run_install --only claude --skip tmux; echo $?)" != 0
check "empty --only rejected" test "$(run_install --only ,; echo $?)" != 0

if [ "$failures" -ne 0 ]; then
    echo "$failures check(s) failed"
    exit 1
fi
echo "All checks passed"

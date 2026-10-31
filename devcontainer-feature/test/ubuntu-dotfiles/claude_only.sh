#!/bin/bash
set -e

echo "Testing ubuntu-dotfiles feature with only the Claude config..."

for file in settings.json CLAUDE.md AGENTS.md; do
    if [ ! -f "$HOME/.claude/$file" ]; then
        echo "FAIL: ~/.claude/$file was not installed"
        exit 1
    fi
done
echo "PASS: Claude config installed"

for path in .zshrc .oh-my-zsh .tmux.conf ubuntu-dotfiles; do
    if [ -e "$HOME/$path" ]; then
        echo "FAIL: ~/$path should not exist"
        exit 1
    fi
done
echo "PASS: zsh, tmux and repo clone were skipped"

if grep -q "ubuntu-dotfiles" "$HOME/workspace.code-workspace"; then
    echo "FAIL: workspace should not include ubuntu-dotfiles when the repo is not cloned"
    exit 1
fi
echo "PASS: workspace does not reference the skipped clone"

echo "All tests passed!"

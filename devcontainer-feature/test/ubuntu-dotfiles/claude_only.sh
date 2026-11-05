#!/bin/bash
set -e

echo "Testing ubuntu-dotfiles feature with only the Claude config..."

for file in settings.json AGENTS.md; do
    if [ ! -f "$HOME/.claude/$file" ]; then
        echo "FAIL: ~/.claude/$file was not installed"
        exit 1
    fi
done
echo "PASS: Claude config installed"

if [ ! -f "$HOME/.claude/skills/repo-scaffolding/SKILL.md" ]; then
    echo "FAIL: the repo-scaffolding skill was not installed"
    exit 1
fi
echo "PASS: Claude skills installed"

if ! find "$HOME/.claude/skills" -name SKILL.md -type f 2>/dev/null | grep -q .; then
    echo "FAIL: no Claude skills were installed under ~/.claude/skills"
    exit 1
fi
echo "PASS: Claude skills installed"

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

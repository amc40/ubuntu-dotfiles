#!/bin/bash
set -e

echo "Testing ubuntu-dotfiles feature..."

if ! command -v zsh &>/dev/null; then
    echo "FAIL: zsh is not installed"
    exit 1
fi
echo "PASS: zsh is installed"

if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "FAIL: oh-my-zsh is not installed"
    exit 1
fi
echo "PASS: oh-my-zsh is installed"

if ! grep -q 'ZSH_THEME="agnoster"' "$HOME/.zshrc"; then
    echo "FAIL: .zshrc does not have agnoster theme"
    exit 1
fi
echo "PASS: .zshrc has agnoster theme"

ZSH_PATH="$(which zsh)"
CURRENT_SHELL="$(getent passwd "$(whoami)" | cut -d: -f7)"
if [ "$CURRENT_SHELL" != "$ZSH_PATH" ]; then
    echo "FAIL: default shell is not zsh (got $CURRENT_SHELL, expected $ZSH_PATH)"
    exit 1
fi
echo "PASS: default shell is zsh"

ZSHRC_OWNER="$(stat -c '%U' "$HOME/.zshrc")"
if [ "$ZSHRC_OWNER" != "$(whoami)" ]; then
    echo "FAIL: .zshrc is owned by $ZSHRC_OWNER, expected $(whoami)"
    exit 1
fi
echo "PASS: .zshrc is owned by the remote user"

echo "All tests passed!"

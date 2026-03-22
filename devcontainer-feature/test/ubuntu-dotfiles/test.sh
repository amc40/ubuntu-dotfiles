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

if ! command -v tmux &> /dev/null; then
    echo "FAIL: tmux is not installed"
    exit 1
fi
echo "PASS: tmux is installed"

if [ "$(stat -c '%U' "$HOME/.tmux.conf")" != "$(whoami)" ]; then
    echo "FAIL: .tmux.conf is not owned by $(whoami)"
    exit 1
fi
echo "PASS: .tmux.conf is owned by the current user"

if [ ! -d "$HOME/ubuntu-dotfiles/.git" ]; then
    echo "FAIL: ubuntu-dotfiles is not a git repository"
    exit 1
fi
echo "PASS: ubuntu-dotfiles is a git repository"

REMOTE_URL="$(cd "$HOME/ubuntu-dotfiles" && git remote get-url origin)"
if [ "$REMOTE_URL" != "https://github.com/amc40/ubuntu-dotfiles.git" ]; then
    echo "FAIL: ubuntu-dotfiles remote is $REMOTE_URL, expected https://github.com/amc40/ubuntu-dotfiles.git"
    exit 1
fi
echo "PASS: ubuntu-dotfiles has correct remote configured"

echo "All tests passed!"

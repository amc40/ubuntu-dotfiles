#!/bin/bash
set -euxo pipefail

USERNAME="${USERNAME:-$(whoami)}"
USER_HOME="${USER_HOME:-$HOME}"
DOTFILES_PATH="${DOTFILES_PATH:-$(cd "$(dirname "$0")" && pwd)}"

## OH MY ZSH

sudo apt-get update
sudo apt-get install -y zsh wget git sudo curl tmux

if [ ! -d "$USER_HOME/.oh-my-zsh" ]; then
    echo "Installing oh-my-zsh"
    su "$USERNAME" -c 'CHSH=no KEEP_ZSHRC=yes RUNZSH=no sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"'
fi

cp "$DOTFILES_PATH/.zshrc" "$USER_HOME/.zshrc"
sudo chown "$USERNAME:$USERNAME" "$USER_HOME/.zshrc"

sudo usermod -s "$(which zsh)" "$USERNAME"


## CLAUDE

if ! command -v claude &> /dev/null; then
    echo "Installing Claude Code"
    su "$USERNAME" -c "curl -fsSL https://claude.ai/install.sh | bash"
fi

mkdir -p "$USER_HOME/.claude"
cp "$DOTFILES_PATH/.claude/settings.json" "$USER_HOME/.claude/settings.json"
cp "$DOTFILES_PATH/.claude/CLAUDE.md" "$USER_HOME/.claude/CLAUDE.md"
sudo chown -R "$USERNAME:$USERNAME" "$USER_HOME/.claude"


## TMUX

cp "$DOTFILES_PATH/.tmux.conf" "$USER_HOME/.tmux.conf"
sudo chown "$USERNAME:$USERNAME" "$USER_HOME/.tmux.conf"


## GIT

repo_path="$USER_HOME/ubuntu-dotfiles"
if [ ! -d "$repo_path" ]; then
    su "$USERNAME" -c "git clone https://github.com/amc40/ubuntu-dotfiles.git '$repo_path'"
fi
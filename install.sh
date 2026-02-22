#!/bin/bash
set -euxo pipefail

USERNAME="${USERNAME:-$(whoami)}"
USER_HOME="${USER_HOME:-$HOME}"
DOTFILES_PATH="${DOTFILES_PATH:-$USER_HOME/ubuntu-dotfiles}"

sudo apt-get update
sudo apt-get install -y zsh wget git sudo

if [ ! -d "$USER_HOME/.oh-my-zsh" ]; then
    echo "Installing oh-my-zsh"
    su "$USERNAME" -c 'CHSH=no KEEP_ZSHRC=yes RUNZSH=no sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"'
fi

cp "$DOTFILES_PATH/.zshrc" "$USER_HOME/.zshrc"

sudo usermod -s "$(which zsh)" "$USERNAME"

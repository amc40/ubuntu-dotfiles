#!/bin/bash
set -euxo pipefail

USER_HOME="${USER_HOME:-$HOME}"
DOTFILES_PATH="${DOTFILES_PATH:-$USER_HOME/ubuntu-dotfiles}"

sudo apt update

sudo apt install zsh -y

if [ ! -d "$USER_HOME/.oh-my-zsh" ]
then
    echo "Installing oh-my-zsh"
    CHSH=no KEEP_ZSHRC=yes RUNZSH=no sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

(cd $DOTFILES_PATH && cat .zshrc > "$USER_HOME/.zshrc")

sudo usermod -s $(which zsh) $(whoami)


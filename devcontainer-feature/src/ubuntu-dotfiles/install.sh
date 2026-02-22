#!/bin/bash
set -euxo pipefail

USERNAME="${_REMOTE_USER:-root}"
USER_HOME="${_REMOTE_USER_HOME:-$(getent passwd "$USERNAME" | cut -d: -f6)}"

apt-get update
apt-get install -y git sudo

su "$USERNAME" -c "git clone https://github.com/amc40/ubuntu-dotfiles $USER_HOME/ubuntu-dotfiles"

export USERNAME
export USER_HOME
export DOTFILES_PATH="$USER_HOME/ubuntu-dotfiles"

bash "$USER_HOME/ubuntu-dotfiles/install.sh"

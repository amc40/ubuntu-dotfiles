#!/bin/bash
set -euxo pipefail

USERNAME="${_REMOTE_USER:-root}"
USER_HOME="${_REMOTE_USER_HOME:-$(getent passwd "$USERNAME" | cut -d: -f6)}"

apt-get update
apt-get install -y sudo

mkdir -p "$USER_HOME/ubuntu-dotfiles"
tar -xzf dotfiles.tar.gz -C "$USER_HOME/ubuntu-dotfiles"
chown -R "$USERNAME:$USERNAME" "$USER_HOME/ubuntu-dotfiles"

export USERNAME
export USER_HOME

bash "$USER_HOME/ubuntu-dotfiles/dotfiles/install.sh"

#!/bin/bash
set -euxo pipefail

USERNAME="${_REMOTE_USER:-root}"
USER_HOME="${_REMOTE_USER_HOME:-$(getent passwd "$USERNAME" | cut -d: -f6)}"

apt-get update
apt-get install -y sudo git

# Extract dotfiles to temp directory
temp_dir=$(mktemp -d)
trap "rm -rf '$temp_dir'" EXIT

tar -xzf dotfiles.tar.gz -C "$temp_dir"

export USERNAME
export USER_HOME

bash "$temp_dir/dotfiles/install.sh"

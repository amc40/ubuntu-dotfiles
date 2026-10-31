#!/bin/bash
set -euxo pipefail

USERNAME="${_REMOTE_USER:-root}"
USER_HOME="${_REMOTE_USER_HOME:-$(getent passwd "$USERNAME" | cut -d: -f6)}"
AGENT="${AGENT:-claude}"
# Devcontainer exposes booleans as uppercased env vars. They are not named ZSH
# or TMUX because oh-my-zsh and tmux use those variables themselves.
INSTALLZSH="${INSTALLZSH:-true}"
INSTALLTMUX="${INSTALLTMUX:-true}"
CLONEREPO="${CLONEREPO:-true}"

apt-get update
apt-get install -y sudo git jq

# Extract dotfiles to temp directory
temp_dir=$(mktemp -d)
trap "rm -rf '$temp_dir'" EXIT

tar -xzf dotfiles.tar.gz -C "$temp_dir"

export USERNAME
export USER_HOME
export AGENT

skip=""
[ "$INSTALLZSH" = "true" ] || skip="$skip,zsh"
[ "$INSTALLTMUX" = "true" ] || skip="$skip,tmux"
[ "$CLONEREPO" = "true" ] || skip="$skip,repo"
skip="${skip#,}"

install_args=()
if [ -n "$skip" ]; then
    install_args=(--skip "$skip")
fi

bash "$temp_dir/dotfiles/install.sh" "${install_args[@]}"

# Create VS Code workspace file
# This will be symlinked or used from the workspace root when VS Code opens the folder
repo_path="$USER_HOME/ubuntu-dotfiles"
workspace_file="$USER_HOME/workspace.code-workspace"

# Initialize workspace if it doesn't exist
if [ ! -f "$workspace_file" ]; then
    echo '{ "folders": [], "settings": {} }' > "$workspace_file"
fi

# Function to add folder if not already present
add_folder_if_missing() {
    local path="$1"
    local workspace="$2"

    # Check if folder already exists in workspace
    if ! jq -e ".folders[] | select(.path == \"$path\")" "$workspace" > /dev/null 2>&1; then
        jq ".folders += [{\"path\": \"$path\"}]" "$workspace" > "${workspace}.tmp" && mv "${workspace}.tmp" "$workspace"
    fi
}

# Add root folder and ubuntu-dotfiles (don't add if already there)
add_folder_if_missing "." "$workspace_file"
if [ "$CLONEREPO" = "true" ]; then
    add_folder_if_missing "$repo_path" "$workspace_file"
fi

chown "$USERNAME:$USERNAME" "$workspace_file"

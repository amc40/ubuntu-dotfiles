#!/bin/bash
set -euxo pipefail

USERNAME="${_REMOTE_USER:-root}"
USER_HOME="${_REMOTE_USER_HOME:-$(getent passwd "$USERNAME" | cut -d: -f6)}"

apt-get update
apt-get install -y sudo git jq

# Extract dotfiles to temp directory
temp_dir=$(mktemp -d)
trap "rm -rf '$temp_dir'" EXIT

tar -xzf dotfiles.tar.gz -C "$temp_dir"

export USERNAME
export USER_HOME

bash "$temp_dir/dotfiles/install.sh"

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
add_folder_if_missing "$repo_path" "$workspace_file"

chown "$USERNAME:$USERNAME" "$workspace_file"

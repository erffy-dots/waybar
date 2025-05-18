#!/usr/bin/env bash

set -euo pipefail

readonly REPO_URL="https://github.com/erffy-dots/waybar.git"
readonly CONFIG_DIR="$HOME/.config/waybar"
readonly BACKUP_DIR="${CONFIG_DIR}.bak"

# Check for Git
if ! command -v git &>/dev/null; then
    echo "Git is not installed. Please install Git first."
    exit 1
fi

echo "Downloading Waybar configuration files from GitHub..."

# Handle existing configuration
if [ -d "$CONFIG_DIR" ]; then
    echo "Existing Waybar configuration detected at '$CONFIG_DIR'."

    # Backup
    if [ -d "$BACKUP_DIR" ]; then
        echo "Removing existing backup at '$BACKUP_DIR'."
        rm -rf "$BACKUP_DIR"
    fi

    echo "Backing up current configuration to '$BACKUP_DIR'."
    cp -r "$CONFIG_DIR" "$BACKUP_DIR"

    echo "Removing old configuration..."
    rm -rf "$CONFIG_DIR"
fi

# Clone repo
echo "Cloning repository..."
git clone "$REPO_URL" "$CONFIG_DIR"

# Validate result
if [ -d "$CONFIG_DIR" ]; then
    echo "Configuration successfully cloned to '$CONFIG_DIR'."
else
    echo "Failed to clone configuration."
    exit 1
fi

# Clean up
rm -rf "$CONFIG_DIR/{.git,README.md,LICENSE,assets,install.sh}"
echo "Removed unnecessary files from '$CONFIG_DIR'."

# Final message
echo
echo "Waybar setup complete."
echo "Please review the files in '$CONFIG_DIR'."
echo "You may need to install additional dependencies for Waybar."
echo "Refer to the Waybar documentation for more information."
echo "If issues arise, visit the GitHub repository for troubleshooting tips."

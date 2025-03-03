#!/bin/bash

set -euo pipefail  # error handling

REPO_URL="https://github.com/Next-Flip/Momentum-Firmware.git"
DEFAULT_CLONE_DIR="$HOME/code/Momentum-Firmware"

# git is required
if ! command -v git &>/dev/null; then
    echo "Error: Git is not installed. Please install git and retry."
    exit 1
fi

# We need to clone it somewhere, I picked here. You can change it.
if [ ! -d "$DEFAULT_CLONE_DIR" ]; then
    read -rp "Directory '$DEFAULT_CLONE_DIR' does not exist. Enter a new directory or press Enter to create: " CLONE_DIR
    CLONE_DIR="${CLONE_DIR:-$DEFAULT_CLONE_DIR}"
    mkdir -p "$CLONE_DIR" || { echo "Failed to create directory '$CLONE_DIR'. Exiting."; exit 1; }
    echo "Created directory: $CLONE_DIR"
else
    CLONE_DIR="$DEFAULT_CLONE_DIR"
fi

cd "$CLONE_DIR" || { echo "Failed to enter directory '$CLONE_DIR'. Exiting."; exit 1; }

# Clone or update the repository
if [ -d ".git" ]; then
    echo "Repository found. Fetching latest updates..."
    git fetch || { echo "Failed to fetch updates. Exiting."; exit 1; }

    LOCAL_HEAD=$(git rev-parse HEAD)
    REMOTE_HEAD=$(git rev-parse @{u} 2>/dev/null || echo "error")

    if [ "$REMOTE_HEAD" = "error" ]; then
        echo "Error: No upstream branch found. Make sure the repository is properly set up."
        exit 1
    fi

    if [ "$LOCAL_HEAD" = "$REMOTE_HEAD" ]; then
        echo "No updates found. Exiting."
        exit 0
    else
        echo "Merging updates..."
        git merge --ff-only || { echo "Failed to merge updates. Exiting."; exit 1; }
    fi
else
    echo "Cloning repository..."
    git clone --recursive --jobs 8 "$REPO_URL" . || { echo "Git clone failed. Exiting."; exit 1; }
fi

# Ensure the flash tool script exists and is executable
if [ ! -f "./fbt" ]; then
    echo "Error: Flash tool script './fbt' not found. Exiting."
    exit 1
fi

chmod +x ./fbt

# Run the flashing script
echo "Starting firmware flashing..."
if ./fbt flash_usb_full; then
    echo "Firmware flashing completed successfully."
else
    echo "Firmware flashing failed. Exiting."
    exit 1
fi


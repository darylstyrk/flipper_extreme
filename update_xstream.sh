#!/bin/bash

# Define the repository URL and the directory to clone into
REPO_URL="https://github.com/Flipper-XFW/Xtreme-Firmware.git"
CLONE_DIR="$HOME/code/Xtreme-Firmware"

# Create the directory if it doesn't exist
mkdir -p "$CLONE_DIR"

# Change to the specified directory
cd "$CLONE_DIR"

# Check if directory change was successful
if [ $? -ne 0 ]; then
    echo "Failed to change directory to $CLONE_DIR. Exiting."
    exit 1
fi

# Check if the repository already exists
if [ -d ".git" ]; then
    echo "Repository already exists. Checking for updates..."

    # Fetch changes from the remote without merging, to check for updates
    git fetch

    # Compare local HEAD with remote HEAD
    LOCAL_HEAD=$(git rev-parse HEAD)
    REMOTE_HEAD=$(git rev-parse @{u})

    if [ "$LOCAL_HEAD" = "$REMOTE_HEAD" ]; then
        echo "No updates found. Exiting."
        exit 0
    else
        echo "Updates found. Merging changes..."
        git merge
        if [ $? -ne 0 ]; then
            echo "Failed to merge updates from the repository. Exiting."
            exit 1
        fi
    fi
else
    echo "Cloning repository for the first time..."
    git clone --recursive --jobs 8 "$REPO_URL" .
    if [ $? -ne 0 ]; then
        echo "Git clone failed. Exiting."
        exit 1
    fi
fi

# Ensure the flash tool script is executable
chmod +x ./fbt

# Check if the executable exists
if [ ! -f ./fbt ]; then
    echo "Flash tool script not found. Exiting."
    exit 1
fi

# Execute the flash tool script
./fbt flash_usb_full

# Check if the flash was successful
if [ $? -ne 0 ]; then
    echo "Flashing failed. Exiting."
    exit 1
fi

echo "Operation completed successfully."

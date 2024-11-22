#!/bin/bash

# Function to check and install sg3-utils if missing
check_and_install_sg3_utils() {
    if ! command -v sg_format &> /dev/null; then
        echo "'sg_format' (from 'sg3-utils') is not installed."
        read -p "Do you want to install 'sg3-utils' now? (y/N) " install_confirm

        if [[ ! "$install_confirm" =~ ^[Yy]$ ]]; then
            echo "Cannot proceed without 'sg3-utils'. Exiting."
            exit 1
        fi

        # Install sg3-utils
        echo "Installing 'sg3-utils'..."
        sudo apt-get update && sudo apt-get install -y sg3-utils

        # Verify installation success
        if [ $? -ne 0 ]; then
            echo "Error: Failed to install 'sg3-utils'. Please install it manually and retry."
            exit 1
        else
            echo "'sg3-utils' installed successfully."
        fi
    fi
}

# Function to list drives with 0B size and confirm with the user
list_and_confirm_drives() {
    # Get all drives with 0B size from lsblk output
    zero_size_drives=$(lsblk -ln -o NAME,SIZE | awk '$2 == "0B" {print "/dev/" $1}')

    # Check if any drives need formatting
    if [ -z "$zero_size_drives" ]; then
        echo "No drives found with 0B size."
        exit 0
    fi

    # List the drives to the user
    echo "The following drives need to be formatted to 512B sector size:"
    echo "$zero_size_drives"
    
    # Confirm with the user before proceeding
    read -p "Are you sure you want to continue with formatting these drives? (y/N) " confirm

    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo "Operation canceled by the user."
        exit 0
    fi
}

# Check for necessary commands
if ! command -v lsblk &> /dev/null; then
    echo "Error: 'lsblk' is not installed. Please install it and try again."
    exit 1
fi

# Ensure sg3-utils is installed
check_and_install_sg3_utils

# List drives and get confirmation
list_and_confirm_drives

# Format each drive to 512B sector size
for drive in $zero_size_drives; do
    echo "Formatting $drive to 512B sector size..."
    sudo sg_format -v --format --size=512 "$drive"
    if [ $? -eq 0 ]; then
        echo "$drive formatted successfully."
    else
        echo "Error formatting $drive."
    fi
done

echo "All selected drives processed."
#!/bin/bash

# Set the source and destination paths
source_folder_1="agent-actions"
destination_folder="$HOME/Library/Application Support/factorio/mods"
version="0.1.0"
mod_name_1="agent-actions"
zip_file_1="${mod_name_1}_${version}.zip"
temp_folder_1="${mod_name_1}_${version}"

copy_flag=true
custom_destination_folder=""

# Function to check if a directory exists
check_directory_exists() {
    local directory="$1"
    if [ ! -d "$directory" ]; then
        echo "Directory \"$directory\" does not exist."
        exit 1
    fi
}

# Process command line arguments
while getopts ":s" opt; do
    case $opt in
        s)
            copy_flag=true
            custom_destination_folder="${OPTARG}"
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
    esac
done

# If the copy flag is set, check the custom destination folder
if $copy_flag; then
    if [ -z "$custom_destination_folder" ]; then
        custom_destination_folder="/opt/factorio/mods"
    fi

    check_directory_exists "$custom_destination_folder"
fi

# Repeat the following steps for each source folder

# Check if the source folder exists
if [ ! -d "$source_folder_1" ]; then
    echo "Source folder \"$source_folder_1\" does not exist."
    exit 1
fi

# Delete the existing zip file if present in the default destination folder
if [ -f "$destination_folder/$zip_file_1" ]; then
    rm "$destination_folder/$zip_file_1"
fi

# Create a temporary directory
mkdir "$temp_folder_1"

# Copy all the contents of the source folder to the temporary directory
cp -R "$source_folder_1" "$temp_folder_1"

# Change to the temporary directory
pushd "$temp_folder_1"

# Create the zip file
zip -r "../$zip_file_1" .

# Move the zip file to the destination folder
mv "../$zip_file_1" "$destination_folder"

# Copy the zip file to the custom destination folder if the flag is set
if $copy_flag; then
    # Delete the existing zip file if present in the custom destination folder
    if [ -f "$custom_destination_folder/$zip_file_1" ]; then
        rm "$custom_destination_folder/$zip_file_1"
    fi
    cp "$destination_folder/$zip_file_1" "$custom_destination_folder"
fi

# Clean up
popd
rm -rf "$temp_folder_1"

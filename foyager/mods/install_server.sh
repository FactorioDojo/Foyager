#!/bin/bash

# Set the source and destination paths
source_folder_1="agent-actions"
destination_folder="/opt/factorio/mods"
version="0.1.0"
mod_name_1="agent-actions"
zip_file_1="${mod_name_1}_${version}.zip"
temp_folder_1="${mod_name_1}_${version}"

# Repeat the following steps for each source folder

# Check if the source folder exists
if [ ! -d "$source_folder_1" ]
then
    echo "Source folder '${source_folder_1}' does not exist."
    exit 1
fi

# Delete the existing zip file if present
if [ -f "${destination_folder}/${zip_file_1}" ]
then
    rm "${destination_folder}/${zip_file_1}"
fi

# Create a temporary directory
mkdir "$temp_folder_1"

# Copy all the contents of the source folder to the temporary directory
cp -R "$source_folder_1"/* "$temp_folder_1"

# Create the zip file
zip -r "$zip_file_1" "$temp_folder_1"

# Move the zip file to the destination folder
mv "$zip_file_1" "$destination_folder"

# Clean up
rm -rf "$temp_folder_1"

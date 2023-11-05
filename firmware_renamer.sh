#!/bin/bash

# Usage: ./rename_script.sh new_name_part
# Example: ./rename_script.sh summerhouse-router

# Exit on any error
set -e

# Check for the correct number of arguments
if [ "$#" -ne 1 ]; then
    echo "Illegal number of parameters"
    echo "Usage: $0 new_name_part"
    exit 1
fi

# Directory where the file is located
DIR="output"

# The provided part of the new file name, replacing '-' and '_' with '*'
# This makes the pattern more flexible to match both characters
NEW_NAME_PART=$(echo "$1" | sed 's/[-_]/-/g')

# New file suffix
SUFFIX="sysupgrade.bin"

# Construct the file pattern
PATTERN="*$(echo "$1" | sed 's/[-_]/\*/g')*.bin"

# Find the file with the old pattern
FILE_TO_RENAME=$(find "${DIR}" -type f -name "${PATTERN}" -print -quit)

# Check if the file was found
if [[ -z $FILE_TO_RENAME ]]; then
    echo "No file to rename matching the pattern '${PATTERN}'."
    exit 1
fi

# Rename the file
mv "${FILE_TO_RENAME}" "${DIR}/${NEW_NAME_PART}-${SUFFIX}"

echo "File has been renamed to ${NEW_NAME_PART}-${SUFFIX}"

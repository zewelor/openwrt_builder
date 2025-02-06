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

# Construct patterns for sysupgrade.bin and factory.bin
SYS_PATTERN="*$(echo "$1" | sed 's/[-_]/\?/g')*sysupgrade.bin"
FACTORY_PATTERN="*$(echo "$1" | sed 's/[-_]/\?/g')*factory.bin"

echo "Looking for files matching patterns '${SYS_PATTERN}' or '${FACTORY_PATTERN}' in the directory '${DIR}'"

# Find a matching file for either suffix
FILE_TO_RENAME=$(find "${DIR}" -type f \( -name "${SYS_PATTERN}" -o -name "${FACTORY_PATTERN}" \) -print -quit)

# Check if the file was found
if [[ -z $FILE_TO_RENAME ]]; then
    echo "No file to rename matching the patterns."
    exit 1
fi

# Determine the suffix based on the found file's name
if [[ $FILE_TO_RENAME == *sysupgrade.bin ]]; then
    SUFFIX="sysupgrade.bin"
elif [[ $FILE_TO_RENAME == *factory.bin ]]; then
    SUFFIX="factory.bin"
fi

# Rename the file
mv "${FILE_TO_RENAME}" "${DIR}/${NEW_NAME_PART}-${SUFFIX}"

echo "${FILE_TO_RENAME} -> ${NEW_NAME_PART}-${SUFFIX}"

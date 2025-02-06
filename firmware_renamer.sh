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

echo "Looking for file matching pattern '${SYS_PATTERN}' in the directory '${DIR}'"
FILE_TO_RENAME=$(find "${DIR}" -type f -name "${SYS_PATTERN}" -print -quit)
if [[ -n $FILE_TO_RENAME ]]; then
    SUFFIX="sysupgrade.bin"
else
    echo "No sysupgrade.bin found. Looking for file matching pattern '${FACTORY_PATTERN}'"
    FILE_TO_RENAME=$(find "${DIR}" -type f -name "${FACTORY_PATTERN}" -print -quit)
    if [[ -z $FILE_TO_RENAME ]]; then
        echo "No file to rename matching the patterns."
        exit 1
    fi
    SUFFIX="factory.bin"
fi

# Rename the file
mv "${FILE_TO_RENAME}" "${DIR}/${NEW_NAME_PART}-${SUFFIX}"

echo "${FILE_TO_RENAME} -> ${NEW_NAME_PART}-${SUFFIX}"

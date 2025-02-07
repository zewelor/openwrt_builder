#!/bin/bash

# Usage: ./rename_script.sh new_name_part [--dry-run]
# Example: ./rename_script.sh summerhouse-router

# Exit on any error
set -e

# Support for help flag
if [ "$1" = "--help" ]; then
    echo "Usage: $0 new_name_part [--dry-run]"
    exit 0
fi

# Updated argument check: require one or two arguments
if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
    echo "Illegal number of parameters"
    echo "Usage: $0 new_name_part [--dry-run]"
    exit 1
fi

# Determine if dry run is enabled
DRY_RUN=0
if [ "$#" -eq 2 ] && [ "$2" = "--dry-run" ]; then
    DRY_RUN=1
fi

# Check if output directory exists
DIR="output"
if [ ! -d "${DIR}" ]; then
    echo "Directory '${DIR}' does not exist."
    exit 1
fi

# Consolidate pattern transformation
SANITIZED_NAME=$(echo "$1" | sed 's/[-_]/-/g')
PATTERN_CORE=$(echo "$1" | sed 's/[-_]/\?/g')

# Construct patterns for sysupgrade.bin, sysupgrade.itb, and factory.bin
SYS_PATTERN_BIN="*${PATTERN_CORE}*sysupgrade.bin"
SYS_PATTERN_ITB="*${PATTERN_CORE}*sysupgrade.itb"
FACTORY_PATTERN="*${PATTERN_CORE}*factory.bin"

# if-elif-else chain to determine the file to rename
if FILE_TO_RENAME=$(find "${DIR}" -type f -name "${SYS_PATTERN_BIN}" -print -quit) && [[ -n $FILE_TO_RENAME ]]; then
    SUFFIX="sysupgrade.bin"
elif FILE_TO_RENAME=$(find "${DIR}" -type f -name "${SYS_PATTERN_ITB}" -print -quit) && [[ -n $FILE_TO_RENAME ]]; then
    SUFFIX="sysupgrade.itb"
elif FILE_TO_RENAME=$(find "${DIR}" -type f -name "${FACTORY_PATTERN}" -print -quit) && [[ -n $FILE_TO_RENAME ]]; then
    SUFFIX="factory.bin"
else
    echo "No file to rename matching the patterns."
    exit 1
fi

# Dry run check: print action instead of executing mv
if [[ $DRY_RUN -eq 1 ]]; then
    echo "[Dry Run] Would execute: mv \"${FILE_TO_RENAME}\" \"${DIR}/${SANITIZED_NAME}-${SUFFIX}\""
else
    mv "${FILE_TO_RENAME}" "${DIR}/${SANITIZED_NAME}-${SUFFIX}"
    echo "${FILE_TO_RENAME} -> ${SANITIZED_NAME}-${SUFFIX}"
fi

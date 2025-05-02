#!/bin/bash

# Usage: ./rename_script.sh new_name_part [--dry-run]
# Example: ./rename_script.sh ap-michal

# Exit on any error
set -e

# Function to show usage information
show_usage() {
    echo "Usage: $0 new_name_part [--dry-run] [--debug]"
    echo "Examples:"
    echo "  $0 ap-michal"
    echo "  $0 ap-michal --dry-run"
    echo "  $0 ap-michal --debug"
}

# Function to find matching files with a specific pattern
find_matching_files() {
    local pattern=$1
    local suffix=$2

    # Print the pattern we're using for debugging
    [[ $DEBUG -eq 1 ]] && echo "Looking for pattern: $pattern"

    # Use find command for compatibility
    while IFS= read -r file; do
        if [[ -n "$file" ]]; then
            FILES_TO_RENAME+=("$file")
            SUFFIXES+=("$suffix")
            [[ $DEBUG -eq 1 ]] && echo "  Match: $file"
        fi
    done < <(find "${DIR}" -type f -name "${pattern}" 2>/dev/null)

    # Report if matches were found
    local count_before=$COUNT_BEFORE
    local count_after=${#FILES_TO_RENAME[@]}
    if [[ $DEBUG -eq 1 && $count_after -gt $count_before ]]; then
        echo "Found $((count_after - count_before)) matches for $suffix"
    elif [[ $DEBUG -eq 1 ]]; then
        echo "No matches found for $suffix"
    fi
}

# Function to rename a file
rename_file() {
    local source=$1
    local target=$2
    local is_dry_run=$3

    if [[ $is_dry_run -eq 1 ]]; then
        echo "[Dry Run] Would execute: mv \"${source}\" \"${target}\""
        return 0
    else
        mv "${source}" "${target}"
        echo "${source} -> $(basename "${target}")"
        return 1
    fi
}

# Process command line arguments
DEBUG=0
DRY_RUN=0
NAME=""

# Parse arguments
for arg in "$@"; do
    case $arg in
        --help)
            show_usage
            exit 0
            ;;
        --debug)
            DEBUG=1
            ;;
        --dry-run)
            DRY_RUN=1
            ;;
        *)
            if [[ -z "$NAME" ]]; then
                NAME="$arg"
            else
                echo "Error: Multiple name parameters provided"
                show_usage
                exit 1
            fi
            ;;
    esac
done

# Check if name was provided
if [[ -z "$NAME" ]]; then
    echo "Error: No name parameter provided"
    show_usage
    exit 1
fi

[[ $DEBUG -eq 1 ]] && echo "Debug mode enabled"
[[ $DEBUG -eq 1 ]] && echo "Name: $NAME"
[[ $DEBUG -eq 1 && $DRY_RUN -eq 1 ]] && echo "Dry run mode enabled"

# Check if output directory exists
DIR="output"
if [[ ! -d $DIR ]]; then
    echo "Directory '${DIR}' does not exist."
    exit 1
fi

# List all files in output directory for debugging
if [[ $DEBUG -eq 1 ]]; then
    echo "Files in output directory:"
    find "$DIR" -type f -name "*.bin" -o -name "*.itb" | sort | while read -r file; do
        echo "  $(basename "$file")"
    done
fi

# Sanitize the input name for the target filename
SANITIZED_NAME=$(echo "$NAME" | sed 's/[-_]/-/g')

# Initialize arrays to store file paths and their suffixes
FILES_TO_RENAME=()
SUFFIXES=()

# Define patterns to try
# Modified patterns to match OpenWrt filename format
PATTERNS_TO_TRY=(
    # Simple matches for already renamed files
    "*${NAME}*factory.bin"
    "*${NAME}*sysupgrade.bin"
    "*${NAME}*sysupgrade.itb"
)

SUFFIXES_TO_TRY=(
    "factory.bin"
    "sysupgrade.bin"
    "sysupgrade.itb"
)

# Find all matching files using all patterns
COUNT_BEFORE=0
for ((i=0; i<${#PATTERNS_TO_TRY[@]}; i++)); do
    pattern="${PATTERNS_TO_TRY[$i]}"
    suffix="${SUFFIXES_TO_TRY[$i]}"
    find_matching_files "$pattern" "$suffix"
    COUNT_BEFORE=${#FILES_TO_RENAME[@]}
done

# Check if any files were found
if [[ ${#FILES_TO_RENAME[@]} -eq 0 ]]; then
    echo "No files found matching name: $NAME"
    echo "Try running with --debug flag to see the patterns being used."
    exit 1
fi

echo "Found ${#FILES_TO_RENAME[@]} file(s) to rename."

# Process all files
RENAMED_COUNT=0
for ((i=0; i<${#FILES_TO_RENAME[@]}; i++)); do
    # Bash arrays are 0-indexed
    FILE_TO_RENAME="${FILES_TO_RENAME[$i]}"
    SUFFIX="${SUFFIXES[$i]}"
    TARGET_FILENAME="${DIR}/${SANITIZED_NAME}-${SUFFIX}"

    # Check if source and target are identical to avoid unnecessary rename
    if [[ "$FILE_TO_RENAME" == "$TARGET_FILENAME" ]]; then
        echo "Skipping $(basename "$FILE_TO_RENAME") (already has the correct name)"
        continue
    fi

    # Check if target file already exists
    if [[ -f "$TARGET_FILENAME" && "$FILE_TO_RENAME" != "$TARGET_FILENAME" ]]; then
        echo "Warning: Target file already exists: $(basename "$TARGET_FILENAME")"
        if [[ $DRY_RUN -eq 0 ]]; then
            echo "Skipping rename to avoid overwriting existing file."
            continue
        fi
    fi

    # Rename the file and update count if successful
    rename_file "$FILE_TO_RENAME" "$TARGET_FILENAME" "$DRY_RUN"
    RENAMED_COUNT=$((RENAMED_COUNT+$?))
done

# Show summary based on dry run mode
if [[ $DRY_RUN -eq 0 ]]; then
    echo "Successfully renamed ${RENAMED_COUNT} file(s)."
else
    echo "[Dry Run] Would rename ${#FILES_TO_RENAME[@]} file(s)."
fi

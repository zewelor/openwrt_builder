#!/usr/bin/env zsh

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

# Function to find matching files
find_matching_files() {
    local pattern=$1
    local suffix=$2

    # Print the pattern we're using for debugging
    [[ $DEBUG -eq 1 ]] && echo "Looking for pattern: $pattern"

    # In Zsh, we can use glob qualifiers (.) for files
    local matches=(${DIR}/${pattern}(N.))

    [[ $DEBUG -eq 1 && ${#matches} -gt 0 ]] && echo "Found ${#matches} matches for $suffix"
    [[ $DEBUG -eq 1 && ${#matches} -eq 0 ]] && echo "No matches found for $suffix"

    for file in $matches; do
        FILES_TO_RENAME+=($file)
        SUFFIXES+=($suffix)
        [[ $DEBUG -eq 1 ]] && echo "  Match: $file"
    done
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
        echo "${source} -> ${target:t}"  # :t is Zsh modifier for basename
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
    ls -1 $DIR | grep -E '\.bin$|\.itb$' | while read -r file; do
        echo "  $file"
    done
fi

# Sanitize the input name for the target filename
SANITIZED_NAME=${NAME//([-_])/-}

# Initialize arrays to store file paths and their suffixes
typeset -a FILES_TO_RENAME SUFFIXES

# Define patterns to try
# Modified patterns to match OpenWrt filename format
PATTERNS_TO_TRY=(
    # Simple matches for already renamed files
    "*${NAME}-factory.bin"
    "*${NAME}-sysupgrade.bin"
    "*${NAME}-sysupgrade.itb"
)

SUFFIXES_TO_TRY=(
    "factory.bin"
    "sysupgrade.bin"
    "sysupgrade.itb"
)

# Find all matching files using all patterns
for ((i=1; i<=${#PATTERNS_TO_TRY}; i++)); do
    pattern=$PATTERNS_TO_TRY[$i]
    suffix=$SUFFIXES_TO_TRY[$i]
    find_matching_files $pattern $suffix
done

# If still no files found, try with exact filename search using grep
if [[ ${#FILES_TO_RENAME} -eq 0 ]]; then
    [[ $DEBUG -eq 1 ]] && echo "No matches found with patterns, trying direct grep search"

    # Get a list of files with the name in them
    # Use grep -i for case insensitive matching
    for filename in $(ls -1 $DIR | grep -i "${NAME}" | grep -E '\.bin$|\.itb$'); do
        full_path="${DIR}/${filename}"

        if [[ $filename == *"factory.bin" ]]; then
            [[ $DEBUG -eq 1 ]] && echo "  Found factory.bin file: $filename"
            FILES_TO_RENAME+=($full_path)
            SUFFIXES+=("factory.bin")
        elif [[ $filename == *"sysupgrade.bin" ]]; then
            [[ $DEBUG -eq 1 ]] && echo "  Found sysupgrade.bin file: $filename"
            FILES_TO_RENAME+=($full_path)
            SUFFIXES+=("sysupgrade.bin")
        elif [[ $filename == *"sysupgrade.itb" ]]; then
            [[ $DEBUG -eq 1 ]] && echo "  Found sysupgrade.itb file: $filename"
            FILES_TO_RENAME+=($full_path)
            SUFFIXES+=("sysupgrade.itb")
        fi
    done
fi

# Check if any files were found
if [[ ${#FILES_TO_RENAME} -eq 0 ]]; then
    echo "No files found matching name: $NAME"
    echo "Try running with --debug flag to see the patterns being used."
    exit 1
fi

echo "Found ${#FILES_TO_RENAME} file(s) to rename."

# Process all files
RENAMED_COUNT=0
for ((i=1; i<=${#FILES_TO_RENAME}; i++)); do
    # Zsh arrays are 1-indexed
    FILE_TO_RENAME=$FILES_TO_RENAME[$i]
    SUFFIX=$SUFFIXES[$i]
    TARGET_FILENAME="${DIR}/${SANITIZED_NAME}-${SUFFIX}"

    # Check if source and target are identical to avoid unnecessary rename
    if [[ "$FILE_TO_RENAME" == "$TARGET_FILENAME" ]]; then
        echo "Skipping ${FILE_TO_RENAME:t} (already has the correct name)"
        continue
    fi

    # Check if target file already exists
    if [[ -f $TARGET_FILENAME ]]; then
        echo "Warning: Target file already exists: ${TARGET_FILENAME:t}"
        if [[ $DRY_RUN -eq 0 ]]; then
            echo "Skipping rename to avoid overwriting existing file."
            continue
        fi
    fi

    # Rename the file and update count if successful
    rename_file $FILE_TO_RENAME $TARGET_FILENAME $DRY_RUN
    RENAMED_COUNT=$((RENAMED_COUNT+$?))
done

# Show summary based on dry run mode
if [[ $DRY_RUN -eq 0 ]]; then
    echo "Successfully renamed ${RENAMED_COUNT} file(s)."
else
    echo "[Dry Run] Would rename ${#FILES_TO_RENAME} file(s)."
fi

#!/bin/bash

# Resolve the absolute path of the directory where the script is located
START_DIR=$(cd "$(dirname "$(readlink -f "$0")")" && pwd)
PROJECT_IDENTIFIER="makefile"

echo "Start searching and cleaning projects..."

echo "Searching project directory in ${START_DIR}..."
# Use find command to search for directories that meet the criteria
find "$START_DIR" -type f -name "$PROJECT_IDENTIFIER" | while read makefile_path; do
    project_dir=$(dirname "$makefile_path")
    echo "Found project directory: ${project_dir}"
    # Check if the project directory exists before entering
    if [ -d "$project_dir" ]; then
        # Enter the project directory
        cd "$project_dir" || exit
        # Execute make clean
        if make clean; then
            echo "Successfully executed make clean in ${project_dir}"
        else
            echo "Failed to execute make clean in ${project_dir}"
        fi
        # remove $project_dir.v
        last_part=$(echo "$project_dir" | rev | cut -d'/' -f1 | rev)
        echo "Attempting to delete file: ${last_part}.v"
        rm -f "${project_dir}/${last_part}.v"
    else
        echo "Cannot find project directory: ${project_dir}"
    fi
    # Return to the directory where the script is located
    cd "$START_DIR" || exit
done

echo "Project search and cleanup completed."

#!/bin/bash

# Get the directory where this script is located
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Create a temporary directory for packaging
TEMP_DIR=$(mktemp -d)

# Copy all necessary files to the temporary directory
cp "$DIR/info.plist" "$TEMP_DIR/"
cp "$DIR/add_reminder.applescript" "$TEMP_DIR/"
cp "$DIR/add_reminder.sh" "$TEMP_DIR/"
cp "$DIR/icon.png" "$TEMP_DIR/" 2>/dev/null || true  # Copy icon if it exists

# Create the workflow file (it's just a zip file with .alfredworkflow extension)
cd "$TEMP_DIR"
zip -r "$DIR/添加提醒.alfredworkflow" .

# Clean up
rm -rf "$TEMP_DIR"

echo "Workflow package created: $DIR/添加提醒.alfredworkflow"

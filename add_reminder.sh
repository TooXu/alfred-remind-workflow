#!/bin/bash

# Get the directory where this script is located
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Run the AppleScript with the provided arguments
osascript "$DIR/add_reminder.applescript" "$@"

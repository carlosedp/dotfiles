#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Code Image from Clipboard
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 🤖"
# @raycast.argument1 { "type": "text", "placeholder": "Programming Language", "optional": true}
# @raycast.packageName Development Tools

# Documentation:
# @raycast.description Create a code image from clipboard using Silicon
# @raycast.author Carlos Eduardo
# @raycast.authorURL https://github.com/carlosedp

FONTS='B612Mono Liga NerdFont;Monaco'
# BGCOLOR="#006666"
BGCOLOR="##66b2b2"

if ! command -v silicon &> /dev/null
then
    echo "Silicon application could not be found, install it thru Homebrew"
    exit 1
else
    silicon --from-clipboard --font "${FONTS}" --background "${BGCOLOR}" -l "${1:-bash}" --to-clipboard
    osascript -e 'display notification "Code image generated and put into the clipboard!" with title "Raycast script"'
fi

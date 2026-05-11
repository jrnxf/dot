#!/bin/sh
# Install Cursor extensions from the snapshot in config/cursor/extensions.txt.
#
# To refresh the snapshot after installing/removing extensions:
#   cursor --list-extensions > config/cursor/extensions.txt

if ! command -v cursor >/dev/null 2>&1; then
  echo "Cursor CLI not found, skipping extension install."
  echo "Install Cursor and ensure the 'cursor' shell command is on PATH (Cursor > Command Palette > 'Shell Command: Install cursor command')."
  exit 0
fi

EXT_FILE="$(dirname "$0")/../config/cursor/extensions.txt"
if [ ! -f "$EXT_FILE" ]; then
  echo "No extensions snapshot at $EXT_FILE, skipping."
  exit 0
fi

echo "Installing Cursor extensions from $EXT_FILE..."
while IFS= read -r ext; do
  [ -z "$ext" ] && continue
  cursor --install-extension "$ext" --force
done < "$EXT_FILE"

echo "Cursor extensions installed."

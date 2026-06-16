#!/bin/sh
# Install VS Code extensions from the snapshot in config/vscode/extensions.txt.
#
# To refresh the snapshot after installing/removing extensions:
#   code --list-extensions > config/vscode/extensions.txt

if ! command -v code >/dev/null 2>&1; then
  echo "VS Code CLI not found, skipping extension install."
  echo "Install VS Code and ensure the 'code' shell command is on PATH (Code > Command Palette > 'Shell Command: Install code command in PATH')."
  exit 0
fi

EXT_FILE="$(dirname "$0")/../config/vscode/extensions.txt"
if [ ! -f "$EXT_FILE" ]; then
  echo "No extensions snapshot at $EXT_FILE, skipping."
  exit 0
fi

echo "Installing VS Code extensions from $EXT_FILE..."
while IFS= read -r ext; do
  [ -z "$ext" ] && continue
  code --install-extension "$ext" --force
done < "$EXT_FILE"

echo "VS Code extensions installed."

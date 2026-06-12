#!/bin/sh
# One-time migration: wipe all Neovim state so the machine starts from a
# barebones install. Old config is preserved in this repo at config/nvim.bak.
# A sentinel file marks the wipe as done so install re-runs never touch
# Neovim state built after the migration.
set -e

sentinel="${HOME}/.local/state/dotfiles/nvim-wiped"

if [ -f "$sentinel" ]; then
  exit 0
fi

rm -rf \
  "${HOME}/.config/nvim" \
  "${HOME}/.cache/nvim" \
  "${HOME}/.local/share/nvim" \
  "${HOME}/.local/state/nvim"

mkdir -p "$(dirname "$sentinel")"
touch "$sentinel"
echo "Neovim state wiped (one-time migration); sentinel at $sentinel"

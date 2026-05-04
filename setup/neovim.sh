#!/bin/sh
# Wipe all Neovim state so each machine starts from a barebones install.
# Old config is preserved in this repo at config/nvim.bak for reference.
set -e

rm -rf \
  "${HOME}/.config/nvim" \
  "${HOME}/.cache/nvim" \
  "${HOME}/.local/share/nvim" \
  "${HOME}/.local/state/nvim"

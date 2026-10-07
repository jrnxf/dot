#!/usr/bin/env bash
# Applies the machine-local `.work` overlays (README, "Machine-local
# overlays"). They are gitignored, so the flake cannot see them; home.nix runs
# this on every switch instead. Safe to rerun, and with no overlay present it
# only keeps the agent instructions linked to home/AGENTS.md.
#
# Usage: work-overlays.sh <dotfiles checkout> <agent instructions path>
set -euo pipefail

dotfiles=$1
instructions=$2
base="$dotfiles/home/AGENTS.md"
overlay="$dotfiles/home/AGENTS.work.md"
skills="$dotfiles/home/.agents/skills"

# Global agent instructions: Home Manager links Claude, Codex and opencode to
# $instructions. Without an overlay that is a live link to home/AGENTS.md;
# with one it is both files joined, regenerated on the next switch.
mkdir -p "$(dirname "$instructions")"
if [ -f "$overlay" ]; then
  tmp=$(mktemp "$instructions.XXXXXX")
  { cat "$base"; printf '\n'; cat "$overlay"; } > "$tmp"
  chmod 644 "$tmp"
  mv -f "$tmp" "$instructions"
else
  ln -sfn "$base" "$instructions"
fi

# Skills: link each home/.agents/skills/<name>.work/ as <name>, since skill
# names may not contain a dot, everywhere home.nix links the tracked skills.
for dir in "$HOME/.agents/skills" "$HOME/.claude/skills" "$HOME/.codex/skills"; do
  # Drop links this script made to overlays that have since been removed.
  for link in "$dir"/*; do
    [ -L "$link" ] || continue
    target=$(readlink "$link")
    case $target in
      "$skills"/*.work) [ -d "$target" ] || rm "$link" ;;
    esac
  done

  for src in "$skills"/*.work; do
    [ -d "$src" ] || continue
    link="$dir/$(basename "$src" .work)"
    [ "$(readlink "$link" 2>/dev/null)" = "$src" ] && continue
    if [ -e "$link" ] || [ -L "$link" ]; then
      echo "work-overlays: $link already exists, not linking $src" >&2
      continue
    fi
    mkdir -p "$dir"
    ln -s "$src" "$link"
  done
done

#!/usr/bin/env bash
input=$(cat)

# Directory: shorten $HOME to ~
cwd=$(echo "$input" | jq -r '.cwd')
short_dir="${cwd/#$HOME/\~}"

# Git branch (skip locks to avoid blocking)
branch=$(GIT_OPTIONAL_LOCKS=0 git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null)

# Model display name
model=$(echo "$input" | jq -r '.model.display_name // empty')

# Context usage
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# Build the status line
parts=()

# Directory in blue
parts+=("$(printf '\033[34m%s\033[0m' "$short_dir")")

# Git branch in magenta with  symbol
if [ -n "$branch" ]; then
  parts+=("$(printf '\033[35m %s\033[0m' "$branch")")
fi

# Model in dim
if [ -n "$model" ]; then
  parts+=("$(printf '\033[2m%s\033[0m' "$model")")
fi

# Context usage
if [ -n "$used" ]; then
  used_int=$(printf '%.0f' "$used")
  parts+=("$(printf '\033[2mctx:%s%%\033[0m' "$used_int")")
fi

printf '%s' "${parts[*]}"

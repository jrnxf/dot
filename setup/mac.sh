#!/bin/sh
# Set up Homebrew, install packages from the Brewfile, set macOS defaults.
set -e

if ! command -v brew >/dev/null 2>&1; then
  echo "Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  echo "Updating Homebrew"
  brew update
fi

echo "Installing packages"
brew bundle install --file "$(dirname "$0")/../Brewfile"

echo "Changing mac defaults"
# allow dragging windows with ctrl+cmd, and left click dragging inside (works on most windows) ** requires restart
defaults write -g NSWindowShouldDragOnGesture -bool true
# defaults delete -g NSWindowShouldDragOnGesture # to stop this behaviour

#!/bin/sh
# set up homebrew
if [[ $(command -v brew) == "" ]]; then
    echo "Installing Hombrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "Updating Homebrew"
    brew update
fi

echo "Installing packages"
brew bundle install

echo "Changin mac defaults"
# allow dragging windows with ctrl+cmd, and left click dragging inside (works on most windows) ** requires restart
defaults write -g NSWindowShouldDragOnGesture -bool true
# defaults delete -g NSWindowShouldDragOnGesture # to stop this behaviour

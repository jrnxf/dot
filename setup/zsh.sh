#!/bin/sh
# Install the shell environment zshrc and tmux.conf depend on:
# oh-my-zsh, fzf-tab, zsh-autosuggestions (omz custom plugins), tpm, nvm.
# Every step is guarded, so re-runs are no-ops.
set -e

# oh-my-zsh — RUNZSH/CHSH/KEEP_ZSHRC keep the installer from launching a
# shell, changing the login shell, or clobbering the dotbot-linked ~/.zshrc.
if [ ! -d "${HOME}/.oh-my-zsh" ]; then
  echo "Installing oh-my-zsh"
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}"

if [ ! -d "${ZSH_CUSTOM}/plugins/fzf-tab" ]; then
  echo "Installing fzf-tab"
  git clone --depth 1 https://github.com/Aloxaf/fzf-tab "${ZSH_CUSTOM}/plugins/fzf-tab"
fi

if [ ! -d "${ZSH_CUSTOM}/plugins/zsh-autosuggestions" ]; then
  echo "Installing zsh-autosuggestions"
  git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM}/plugins/zsh-autosuggestions"
fi

if [ ! -d "${HOME}/.tmux/plugins/tpm" ]; then
  echo "Installing tpm (tmux plugin manager)"
  git clone --depth 1 https://github.com/tmux-plugins/tpm "${HOME}/.tmux/plugins/tpm"
  echo "NOTE: run prefix + I inside tmux to install tmux plugins."
fi

if [ ! -d "${HOME}/.nvm" ]; then
  echo "Installing nvm"
  curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | PROFILE=/dev/null bash
fi

echo "Shell environment ready."

#!/bin/sh
rm -rf ~/.cache/nvim ~/.config/nvim/plugin ~/.local/share/nvim
git clone --depth 1 https://github.com/wbthomason/packer.nvim ~/.local/share/nvim/site/pack/packer/start/packer.nvim
nvim --headless -u NONE -c 'lua require("jrnxf.lib.reload").full_reload()' -c 'PackerSync' -c 'au User MasonToolsUpdateCompleted quitall'

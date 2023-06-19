-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.opt.swapfile = false

-- these must remain zero when I have a transaperent terminal background!
vim.opt.pumblend = 0
vim.opt.winblend = 0

vim.opt.fillchars = {
  foldopen = "",
  foldclose = "",
  fold = " ",
  foldsep = "╏",
  diff = "╱",
  eob = " ",
}
vim.opt.cmdheight = 0
vim.opt.showmatch = true
vim.opt.matchtime = 3
require("util.status")

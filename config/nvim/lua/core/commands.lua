vim.cmd [[
    augroup highlight_yank
      au!
      au TextYankPost * silent! lua vim.highlight.on_yank { timeout = 200 }
    augroup END
]]

vim.cmd 'command! NvimReload lua require"core.utils".reload_nvim_conf()'

-- hi Normal guibg=NONE ctermbg=NONE
vim.cmd [[
 augroup NordOverrides
  au colorscheme * :hi normal guibg=NONE ctermbg=NONE
 augroup END
]]

vim.cmd [[
    augroup highlight_yank
      au!
      au TextYankPost * silent! lua vim.highlight.on_yank { timeout = 200 }
    augroup END
]]

vim.cmd 'command! Reload lua require"core.utils".reload_nvim_conf()'

-- -- paste this above to override nord background
-- augroup NordOverrides
--     au colorscheme nord :hi normal guibg=#2C313C
-- augroup END

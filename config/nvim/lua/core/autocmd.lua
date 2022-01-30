vim.cmd[[
    augroup highlight_yank
      au!
      au TextYankPost * silent! lua vim.highlight.on_yank { timeout = 150 }
    augroup END

]]


-- -- paste this above to override nord background
-- augroup NordOverrides
--     autocmd colorscheme nord :hi normal guibg=#2C313C
-- augroup END


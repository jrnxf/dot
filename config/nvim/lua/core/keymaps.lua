local u = require('core.utils')

vim.g.mapleader = ' '
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

u.map('n', '<leader>', '<Nop>')
u.map('x', '<leader>', '<Nop>')
-- Normal
u.map('n', 'Q', '<Nop>')
u.map('n', 'q:', '<Nop>')
u.map('n', 'Y', 'y$')
u.map('n', '<CR>', '{->v:hlsearch ? ":nohl\\<CR>" : "\\<CR>"}()', { expr = true })
u.map('n', 'x', '"_x')
u.map('n', 'X', '"_X')

-- Map `Y` to copy to end of line
-- conistent with the behaviour of `C` and `D`
u.map('n', 'Y', 'y$', { noremap = true })
u.map('v', 'Y', '<Esc>y$gv', { noremap = true })

-- Keep matches center screen when cycling with n|N
u.map('n', 'n', 'nzzzv', { noremap = true })
u.map('n', 'N', 'Nzzzv', { noremap = true })

-- Navigate buffers
u.map('n', '[b', ':bprevious<CR>', { noremap = true })
u.map('n', ']b', ':bnext<CR>', { noremap = true })
u.map('n', '[B', ':bfirst<CR>', { noremap = true })
u.map('n', ']B', ':blast<CR>', { noremap = true })

u.map('n', '<leader>q', ':q!<CR>')
u.map('n', '<leader>bq', ':Bdelete<CR>') -- uses bbye

u.map('n', '<leader>w', ':update<CR>')

-- Window
u.map('n', '<Up>', ':wincmd -<CR>')
u.map('n', '<Down>', ':wincmd +<CR>')
u.map('n', '<Left>', ':wincmd <<CR>')
u.map('n', '<Right>', ':wincmd ><CR>')
u.map('n', '<leader>=', ':wincmd =<CR>')
u.map('n', '<leader>=', ':Wincmd =<CR>')

-- visual
-- (un)indent lines
u.map('v', '<', '<gv')
u.map('v', '>', '>gv')
-- shift lines up or down
u.map('v', 'K', ":move '<-2<cr>gv-gv")
u.map('v', 'J', ":move '>+1<cr>gv-gv")

u.map('v', '<leader>d', '"_d')
-- send highlighted text to void register and paste (maintain your paste)
u.map('v', '<leader>p', '"_dP')

-- Command
u.map('c', '<C-a>', '<Home>', { silent = false })
u.map('c', '<C-e>', '<End>', { silent = false })
u.map('c', '<C-h>', '<Left>', { silent = false })
u.map('c', '<C-j>', '<Down>', { silent = false })
u.map('c', '<C-k>', '<Up>', { silent = false })
u.map('c', '<C-l>', '<Right>', { silent = false })
u.map('c', '<C-d>', '<Del>', { silent = false })
u.map('c', '<C-f>', '<C-R>=expand("%:p")<CR>', { silent = false }) -- prints the current file path

-- Splits
u.map('n', 'vs', ':vs<CR>')
u.map('n', 'sp', ':sp<CR>')

-- Git
u.map('n', 'gs', ':G<CR>') -- theirs
u.map('n', 'gj', ':diffget //2<CR>') -- theirs
u.map('n', 'gk', ':diffget //3<CR>') -- mine

u.map('n', '<leader>re', ':NvimReload<CR> | :PackerSync<CR>')

-- Search and Replace
-- 'c.' for word, '<leader>c.' for WORD
u.map('n', 'c.', [[:%s/\<<C-r><C-w>\>//g<Left><Left>]], { noremap = true })
u.map('n', '<leader>c.', [[:%s/\<<C-r><C-a>\>//g<Left><Left>]], { noremap = true })

-- Turn off search matches with double-<Esc>
u.map('n', '<Esc><Esc>', '<Esc>:nohlsearch<CR>', { noremap = true, silent = true })

-- Map <leader>o & <leader>O to newline without insert mode
u.map('n', '<leader>o', ':<C-u>call append(line("."), repeat([""], v:count1))<CR>', { noremap = true, silent = true })
u.map('n', '<leader>O', ':<C-u>call append(line(".")-1, repeat([""], v:count1))<CR>', {
  noremap = true,
  silent = true,
})

-- jump to the next item, skipping the group = true});
local M = {}

return M

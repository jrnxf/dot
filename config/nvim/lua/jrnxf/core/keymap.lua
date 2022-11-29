require('jrnxf.lib.keymap')

local u = require('jrnxf.core.utils')

vim.g.mapleader = ' '
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

nmap('<leader>', '<Nop>')
u.map('x', '<leader>', '<Nop>')
-- Normal
nmap('Q', '<Nop>')
nmap('q:', '<Nop>')
nmap('Y', 'y$')
nmap('<CR>', '{->v:hlsearch ? ":nohl\\<CR>" : "\\<CR>"}()', { expr = true })
nmap('x', '"_x')
nmap('X', '"_X')

-- Map `Y` to copy to end of line
-- conistent with the behaviour of `C` and `D`
nmap('Y', 'y$', { noremap = true })
u.map('v', 'Y', '<Esc>y$gv', { noremap = true })

-- Keep matches center screen when cycling with n|N
nmap('n', 'nzzzv', { noremap = true })
nmap('N', 'Nzzzv', { noremap = true })

-- Window
nmap('<Up>', ':wincmd 2+<CR>')
nmap('<Down>', ':wincmd 2-<CR>')
nmap('<Left>', ':wincmd 2><CR>')
nmap('<Right>', ':wincmd 2<<CR>')
nmap('<leader>=', ':wincmd =<CR>')

-- visual
-- (un)indent lines
vmap('<', '<gv')
vmap('>', '>gv')
-- shift lines up or down
vmap('K', ":move '<-2<cr>gv-gv")
vmap('J', ":move '>+1<cr>gv-gv")

vmap('<leader>d', '"_d')
-- send highlighted text to void register and paste (maintain your paste)
vmap('<leader>p', '"_dP')

-- Command
cmap('<C-a>', '<Home>', { silent = false })
cmap('<C-e>', '<End>', { silent = false })
cmap('<C-h>', '<Left>', { silent = false })
cmap('<C-j>', '<Down>', { silent = false })
cmap('<C-k>', '<Up>', { silent = false })
cmap('<C-l>', '<Right>', { silent = false })
cmap('<C-d>', '<Del>', { silent = false })
cmap('<C-f>', '<C-R>=expand("%:p")<CR>', { silent = false }) -- prints the current file path

nmap('j', 'gj')
nmap('k', 'gk')

nmap('<F1>', ":lua require('jrnxf.core.utils').exec_file()<cr>") -- exec current file
nmap('<F2>', ":lua require('jrnxf.core.utils').open_url_under_cursor()<cr>")
nmap('<F3>', "<cmd>lua require('jrnxf.lib.reload').full_reload()<cr>", { noremap = true, silent = true })
nmap('<leader>fr', "<cmd>lua require('jrnxf.lib.reload').full_reload()<cr>", { noremap = true, silent = true })

-- open to gh location in browser
nmap('<leader>gB', function()
  local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ':~:.')
  local line, _ = unpack(vim.api.nvim_win_get_cursor(0))
  local cmd = { 'gh', 'browse', filename .. ':' .. line }

  local jobid = vim.fn.jobstart(cmd)
  vim.fn.jobwait({ jobid })
end, { desc = 'Browse file' })

-- Git
nmap('gs', ':0G<CR>') -- theirs
nmap('gj', ':diffget //2<CR>') -- theirs
nmap('gk', ':diffget //3<CR>') -- mine

-- Search and Replace
-- 'c.' for word, '<leader>c.' for WORD
nmap('c.', [[:%s/\<<C-r><C-w>\>//g<Left><Left>]], { noremap = true })
nmap('<leader>c.', [[:%s/\<<C-r><C-a>\>//g<Left><Left>]], { noremap = true })

-- Turn off search matches with double-<Esc>
nmap('<Esc><Esc>', '<Esc>:nohlsearch<CR>', { noremap = true, silent = true })

-- Map <leader>o & <leader>O to newline without insert mode
nmap('<leader>o', ':<C-u>call append(line("."), repeat([""], v:count1))<CR>', { noremap = true, silent = true })
nmap('<leader>O', ':<C-u>call append(line(".")-1, repeat([""], v:count1))<CR>', {
  noremap = true,
  silent = true,
})

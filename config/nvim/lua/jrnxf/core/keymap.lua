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
nmap('<cr>', '{->v:hlsearch ? ":nohl\\<cr>" : "\\<cr>"}()', { expr = true })
nmap('x', '"_x')
nmap('X', '"_X')

-- Map `Y` to copy to end of line
-- conistent with the behaviour of `C` and `D`
nmap('Y', 'y$')
u.map('v', 'Y', '<Esc>y$gv')

-- Keep matches center screen when cycling with n|N
nmap('n', 'nzzzv')
nmap('N', 'Nzzzv')

-- Window
nmap('<Up>', ':wincmd 2+<cr>')
nmap('<Down>', ':wincmd 2-<cr>')
nmap('<Left>', ':wincmd 2><cr>')
nmap('<Right>', ':wincmd 2<<cr>')
nmap('<leader>=', ':wincmd =<cr>')

nmap('<C-h>', '<C-w>h')
nmap('<C-j>', '<C-w>j')
nmap('<C-k>', '<C-w>k')
nmap('<C-l>', '<C-w>l')

-- visual
-- (un)indent lines
vmap('<', '<gv')
vmap('>', '>gv')
-- shift lines up or down
vmap('K', ":move '<-2<cr>gv-gv")
vmap('J', ":move '>+1<cr>gv-gv")

-- delete to void register (acts as a motion in normal mode)
kmap({ 'n', 'v' }, '<leader>d', '"_d')
-- send highlighted text to void register and paste (maintain your paste)
vmap('<leader>p', '"_dP')

-- Command (silent = false is necessary bc the cmdline needs to be able to
-- update itself)
cmap('<C-a>', '<Home>', { silent = false })
cmap('<C-e>', '<End>', { silent = false })
cmap('<C-h>', '<Left>', { silent = false })
cmap('<C-j>', '<Down>', { silent = false })
cmap('<C-k>', '<Up>', { silent = false })
cmap('<C-l>', '<Right>', { silent = false })
cmap('<C-f>', '<C-R>=expand("%:p")<cr>', { silent = false }) -- prints the current file path

-- repect multilines
nmap('j', 'gj')
nmap('k', 'gk')

nmap('<leader>w', ':wall!<cr>')
nmap('<leader>q', ':qall!<cr>')

nmap('<F1>', ":lua require('jrnxf.core.utils').exec_file()<cr>") -- exec current file
nmap('<F2>', ":lua require('jrnxf.core.utils').open_url_under_cursor()<cr>")
nmap('<F3>', ":lua require('jrnxf.lib.reload').full_reload()<cr>")
nmap('<leader>fr', ":lua require('jrnxf.lib.reload').full_reload()<cr>")

-- open to gh location in browser
nmap('<leader>gB', function()
  local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ':~:.')
  local line, _ = unpack(vim.api.nvim_win_get_cursor(0))
  local cmd = { 'gh', 'browse', filename .. ':' .. line }

  local jobid = vim.fn.jobstart(cmd)
  vim.fn.jobwait({ jobid })
end, { desc = 'Browse file' })

-- Git
nmap('gs', ':0G<cr>') -- theirs
nmap('gj', ':diffget //2<cr>') -- theirs
nmap('gk', ':diffget //3<cr>') -- mine

-- Search and Replace
-- 'c.' for word, '<leader>c.' for WORD
nmap('c.', [[:%s/\<<C-r><C-w>\>//g<Left><Left>]])
nmap('<leader>c.', [[:%s/\<<C-r><C-a>\>//g<Left><Left>]])

-- Turn off search matches with double-<Esc>
nmap('<Esc><Esc>', '<Esc>:nohlsearch<cr>')

-- Map <leader>o & <leader>O to newline without insert mode
nmap('<leader>o', ':<C-u>call append(line("."), repeat([""], v:count1))<cr>')
nmap('<leader>O', ':<C-u>call append(line(".")-1, repeat([""], v:count1))<cr>')

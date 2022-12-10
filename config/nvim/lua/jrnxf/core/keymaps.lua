require('jrnxf.lib.keymaps')

vim.g.mapleader = ' '
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

nmap('<leader>', '<Nop>')
xmap('<leader>', '<Nop>')
-- Normal
nmap('Q', '<Nop>')
nmap('q:', '<Nop>')
nmap('Y', 'y$')
-- nmap('<CR>', '{->v:hlsearch ? ":nohl\\<CR>" : "\\<CR>"}()', { expr = true })
nmap('x', '"_x')
nmap('X', '"_X')

-- Map `Y` to copy to end of line
-- conistent with the behaviour of `C` and `D`
nmap('Y', 'y$')
vmap('Y', '<Esc>y$gv')

nmap('<leader>v', ':vsplit<CR>')
nmap('<leader>s', ':split<CR>')

-- Keep matches center screen when cycling with n|N
nmap('n', 'nzzzv') -- zv is fold related
nmap('N', 'Nzzzv')

-- half screen up/down keeping cursor centered
-- nmap('<C-d>', '<C-d>zz')
-- nmap('<C-u>', '<C-u>zz')

-- <CR> acts as normal, but when things are activly highlighted <CR> will
-- nohighlight as well
nmap('<Esc><Esc>', ':nohlsearch<CR>')
nmap('<CR>', ':nohlsearch<CR><CR>')

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
vmap('K', ":move '<-2<CR>gv-gv")
vmap('J', ":move '>+1<CR>gv-gv")

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
cmap('<C-f>', '<C-R>=expand("%:p")<CR>', { silent = false }) -- prints the current file path

-- repect multilines
nmap('j', 'gj')
nmap('k', 'gk')

nmap('<leader>w', ':wall!<CR>')
nmap('<leader>q', ':qall!<CR>')

nmap('<F1>', function()
  require('jrnxf.lib.utils').exec_current_file()
end)
nmap('<F2>', function()
  require('jrnxf.lib.utils').open_url_under_cursor()
end)
nmap('<F3>', function()
  require('jrnxf.lib.reload').full_reload()
end)
nmap('<leader>fr', function()
  require('jrnxf.lib.reload').full_reload()
end)

-- open to gh location in browser
nmap('<leader>gB', function()
  local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ':~:.')
  local line, _ = unpack(vim.api.nvim_win_get_cursor(0))
  local cmd = { 'gh', 'browse', filename .. ':' .. line }

  local jobid = vim.fn.jobstart(cmd)
  vim.fn.jobwait({ jobid })
end, { desc = 'Browse file' })

-- Git
nmap('gs', ':0G<CR>')
nmap('gj', ':diffget //2<CR>') -- theirs
nmap('gk', ':diffget //3<CR>') -- mine

-- Search and Replace
-- 'c.' for word
nmap('c.', [[:%s/\<<C-r><C-w>\>//g<Left><Left>]], { silent = false })

-- Map <leader>o & <leader>O to newline without insert mode

nmap('<leader>o', ':<C-u>call append(line("."), repeat([""], v:count1))<CR>')
nmap('<leader>O', ':<C-u>call append(line(".")-1, repeat([""], v:count1))<CR>')

nmap('[b', ':bprev<CR>')
nmap(']b', ':bnext<CR>')
nmap('<leader>bq', ':bdelete<CR>')
nmap('[t', ':tabprev<CR>')
nmap(']t', ':tabnext<CR>')
nmap('<leader>tq', ':tabclose<CR>')

nmap('<leader>gd', ':DiffviewOpen<CR>')
nmap('<leader>gh', ':DiffviewFileHistory<CR>')
nmap('<leader>gH', ':DiffviewFileHistory %<CR>')
xmap('<leader>gh', "<Esc>:'<,'>DiffviewFileHistory<CR>")
-- nmap('<leader>', '')
-- nmap('<leader>', '')
-- nmap('<leader>', '')

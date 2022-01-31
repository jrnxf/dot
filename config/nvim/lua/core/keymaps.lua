local u = require 'core.utils'

vim.g.mapleader = ' '
u.map('n', '<leader>', '<Nop>')
u.map('x', '<leader>', '<Nop>')

-- Normal
u.map('n', 'Q', '<Nop>')
u.map('n', 'q:', '<Nop>')
u.map('n', 'Y', 'y$')
u.map('n', '<CR>', '{->v:hlsearch ? ":nohl\\<CR>" : "\\<CR>"}()', { expr = true })
u.map('n', 'x', '"_x')
u.map('n', 'X', '"_X')

u.map('n', '<C-s>', '<cmd>update!<CR>')
u.map('n', '<C-q>', '<cmd>q!<CR>')

u.map('n', '<F9>', '<cmd>lua require"core.compiler".compile_and_run()<CR>')

-- Buffers
u.map('n', '<Tab>', '<cmd>bn<CR>')
u.map('n', '<S-Tab>', '<cmd>bp<CR>')
u.map('n', '<leader>d', '<cmd>Bdelete<CR>') -- uses bbye

-- Window
u.map('n', '<C-h>', '<cmd>wincmd h<CR>')
u.map('n', '<C-j>', '<cmd>wincmd j<CR>')
u.map('n', '<C-k>', '<cmd>wincmd k<CR>')
u.map('n', '<C-l>', '<cmd>wincmd l<CR>')
u.map('n', '<Up>', '<cmd>wincmd -<CR>')
u.map('n', '<Down>', '<cmd>wincmd +<CR>')
u.map('n', '<Left>', '<cmd>wincmd <<CR>')
u.map('n', '<Right>', '<cmd>wincmd ><CR>')
u.map('n', '<leader>=', '<cmd>wincmd =<CR>')

-- Insert
u.map('i', 'kj', '<Esc>')
u.map('i', 'jk', '<Esc>')
u.map('i', '<C-c>', '<Esc>')
u.map('i', '<S-CR>', '<Esc>o')
u.map('i', '<C-CR>', '<Esc>O')

-- Visual
u.map('x', '<', '<gv')
u.map('x', '>', '>gv')
u.map('x', 'K', ":move '<-2<CR>gv-gv")
u.map('x', 'J', ":move '>+1<CR>gv-gv")

-- Terminal
u.map('t', '<C-w>h', '<cmd>wincmd h<CR>')
u.map('t', '<C-w>j', '<cmd>wincmd j<CR>')
u.map('t', '<C-w>k', '<cmd>wincmd k<CR>')
u.map('t', '<C-w>l', '<cmd>wincmd l<CR>')
u.map('t', '<C-w><C-h>', '<cmd>wincmd h<CR>')
u.map('t', '<C-w><C-j>', '<cmd>wincmd j<CR>')
u.map('t', '<C-w><C-k>', '<cmd>wincmd k<CR>')
u.map('t', '<C-w><C-l>', '<cmd>wincmd l<CR>')

-- Command
u.map('c', '<C-a>', '<Home>', { silent = false })
u.map('c', '<C-e>', '<End>', { silent = false })
u.map('c', '<C-h>', '<Left>', { silent = false })
u.map('c', '<C-j>', '<Down>', { silent = false })
u.map('c', '<C-k>', '<Up>', { silent = false })
u.map('c', '<C-l>', '<Right>', { silent = false })
u.map('c', '<C-d>', '<Del>', { silent = false })
u.map('c', '<C-f>', '<C-R>=expand("%:p")<CR>', { silent = false })

-- Telescope
if u.is_git_dir {} == 0 then
  u.map('n', '<C-p>', '<cmd>lua require"telescope.builtin".git_files()<CR>')
else
  u.map('n', '<C-p>', '<cmd>lua require"telescope.builtin".find_files()<CR>')
end
u.map('n', '<space>fb', '<cmd>Telescope buffers theme=get_dropdown<CR>')
u.map('n', '<space>fh', '<cmd>lua require"telescope.builtin".help_tags()<CR>')
u.map('n', '<space>fo', '<cmd>lua require"telescope.builtin".oldfiles()<CR>')
u.map('n', '<space>fw', '<cmd>lua require"telescope.builtin".live_grep()<CR>')
u.map('n', '<space>fd', '<cmd>lua require"telescope.builtin".git_files({cwd = "$HOME/dotfiles" })<CR>')

-- Tree
u.map('n', '<C-n>', '<cmd>NvimTreeToggle<CR>')

-- Vim surround ( noremap need to be false to work)
u.map('n', 'ds', '<Plug>Dsurround', { noremap = false })
u.map('n', 'cs', '<Plug>Csurround', { noremap = false })
u.map('n', 'cS', '<Plug>CSurround', { noremap = false })
u.map('n', 's', '<Plug>Ysurround', { noremap = false })
u.map('n', 'S', '<Plug>YSurround', { noremap = false })
u.map('n', 'ss', '<Plug>Yssurround', { noremap = false })
u.map('n', 'SS', '<Plug>YSsurround', { noremap = false })
u.map('x', 's', '<Plug>VSurround', { noremap = false })
u.map('x', 'S', '<Plug>VgSurround', { noremap = false })

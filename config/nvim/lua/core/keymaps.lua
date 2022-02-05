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

-- Buffers
u.map('n', '<Tab>', ':bn<CR>')
u.map('n', '<S-Tab>', ':bp<CR>')
u.map('n', '<leader>d', ':Bdelete<CR>') -- uses bbye
u.map('n', '<leader><leader>', '<c-^>')

-- Window
u.map('n', '<C-h>', ':wincmd h<CR>')
u.map('n', '<C-j>', ':wincmd j<CR>')
u.map('n', '<C-k>', ':wincmd k<CR>')
u.map('n', '<C-l>', ':wincmd l<CR>')
u.map('n', '<Up>', ':wincmd -<CR>')
u.map('n', '<Down>', ':wincmd +<CR>')
u.map('n', '<Left>', ':wincmd <<CR>')
u.map('n', '<Right>', ':wincmd ><CR>')
u.map('n', '<leader>=', ':wincmd =<CR>')

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
u.map('t', '<C-w>h', ':wincmd h<CR>')
u.map('t', '<C-w>j', ':wincmd j<CR>')
u.map('t', '<C-w>k', ':wincmd k<CR>')
u.map('t', '<C-w>l', ':wincmd l<CR>')
u.map('t', '<C-w><C-h>', ':wincmd h<CR>')
u.map('t', '<C-w><C-j>', ':wincmd j<CR>')
u.map('t', '<C-w><C-k>', ':wincmd k<CR>')
u.map('t', '<C-w><C-l>', ':wincmd l<CR>')

-- Command
u.map('c', '<C-a>', '<Home>', { silent = false })
u.map('c', '<C-e>', '<End>', { silent = false })
u.map('c', '<C-h>', '<Left>', { silent = false })
u.map('c', '<C-j>', '<Down>', { silent = false })
u.map('c', '<C-k>', '<Up>', { silent = false })
u.map('c', '<C-l>', '<Right>', { silent = false })
u.map('c', '<C-d>', '<Del>', { silent = false })
u.map('c', '<C-f>', '<C-R>=expand("%:p")<CR>', { silent = false }) -- prints the current file path

-- Git
u.map('n', 'gs', ':G<CR>') -- theirs
u.map('n', 'gj', ':diffget //2<CR>') -- theirs
u.map('n', 'gk', ':diffget //3<CR>') -- mine

-- Telescope
if u.is_git_dir() == 0 then
  u.map('n', '<C-p>', ':Telescope git_files<CR>')
else
  u.map('n', '<C-p>', ':Telescope find_files<CR>')
end
-- TODO: set up diagnostics for
u.map('n', '<leader>fb', ':Telescope buffers<CR>')
u.map('n', '<leader>fh', ':Telescope help_tags<CR>')
u.map('n', '<leader>fo', ':Telescope oldfiles<CR>')
u.map('n', '<leader>fw', ':Telescope live_grep<CR>')
u.map('n', '<leader>fm', ':Telescope man_pages<CR>')
u.map('n', '<leader>gb', ':Telescope git_branches<CR>')
-- TODO: study if it's possible to write the command below like the ones above (it has params, unlike the others)
u.map('n', '<leader>fd', ':lua require"telescope.builtin".git_files({cwd = "$HOME/dotfiles" })<CR>')

-- Tree
u.map('n', '<C-n>', ':NvimTreeToggle<CR>')

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

-- global quickfix
u.map('n', '<leader>qo', ':copen<CR>')
u.map('n', '<leader>qc', ':cclose<CR>')
u.map('n', '<C-j>', ':cnext<CR>zz')
u.map('n', '<C-k>', ':cprev<CR>zz')

-- location quickfix
u.map('n', '<leader>lo', ':lua vim.diagnostic.setloclist()<CR>') -- will auto open, since location lists are buffer oriented, you have to manually close (refer to below?)
u.map('n', '<leader>lc', ':lclose<CR>') -- kinda confused, this seems to work but is it not possible to have many location lists open?
u.map('n', '<leader>j', ':lnext<CR>zz')
u.map('n', '<leader>k', ':lprev<CR>zz')

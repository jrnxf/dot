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
u.map('n', 'bb', '<c-^>')
u.map('n', '<leader>d', ':Bdelete<CR>') -- uses bbye

u.map('n', '<Tab>', ':ZenMode<CR>')

-- Window
u.map('n', '<Up>', ':wincmd -<CR>')
u.map('n', '<Down>', ':wincmd +<CR>')
u.map('n', '<Left>', ':wincmd <<CR>')
u.map('n', '<Right>', ':wincmd ><CR>')
u.map('n', '<leader>=', ':wincmd =<CR>')

u.map('n', '<leader>w', ':update<CR>')
u.map('n', '<leader>q', ':wincmd =<CR>')
-- Insert
u.map('i', 'kj', '<Esc>')
u.map('i', 'jk', '<Esc>')

-- (un)indent lines
-- visual
u.map('v', '<', '<gv')
u.map('v', '>', '>gv')
-- shift lines up or down
u.map('v', 'K', ":move '<-2<cr>gv-gv")
u.map('v', 'J', ":move '>+1<cr>gv-gv")
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

-- Trouble
u.map('n', '<leader>xw', '<cmd>Trouble workspace_diagnostics<cr>', { silent = true, noremap = true })
u.map('n', '<leader>xx', '<cmd>Trouble<cr>', { silent = true, noremap = true })
u.map('n', '<leader>xd', '<cmd>Trouble document_diagnostics<cr>', { silent = true, noremap = true })
u.map('n', '<leader>xl', '<cmd>Trouble loclist<cr>', { silent = true, noremap = true })
u.map('n', '<leader>xq', '<cmd>Trouble quickfix<cr>', { silent = true, noremap = true })
u.map('n', 'gR', '<cmd>Trouble lsp_references<cr>', { silent = true, noremap = true })
u.map('n', '<C-j>', ':lua require("trouble").next({skip_groups = true, jump = true})<CR>')
u.map('n', '<C-k>', ':lua require("trouble").previous({skip_groups = true, jump = true})<CR>')

-- jump to the next item, skipping the group = true});
local M = {}

-- Buffer LSP
M.set_buffer_lsp_maps = function(bufnr)
  u.buf_map(bufnr, 'n', 'gD', ':LspDeclaration<CR>')
  u.buf_map(bufnr, 'n', 'gd', ':LspDefinition<CR>')
  u.buf_map(bufnr, 'n', 'gt', ':LspTypeDefinition<CR>')
  u.buf_map(bufnr, 'n', 'gr', ':LspReferences<CR>')
  u.buf_map(bufnr, 'n', 'gi', ':LspImplementation<CR>')
  u.buf_map(bufnr, 'n', 'ga', ':LspCodeAction<CR>')
  u.buf_map(bufnr, 'n', 'K', ':LspHover<CR>')
  u.buf_map(bufnr, 'i', '<C-k>', ':LspSignatureHelp<CR>')
  u.buf_map(bufnr, 'n', '<leader>rn', ':LspRename<CR>')
  u.buf_map(bufnr, 'n', '<leader>a', ':LspDiagLine<CR>')
  u.buf_map(bufnr, 'n', '<leader>qf', ':LspDiagQuickfix<CR>')
  u.buf_map(bufnr, 'n', '[a', ':LspDiagPrev<CR>')
  u.buf_map(bufnr, 'n', ']a', ':LspDiagNext<CR>')
end

return M

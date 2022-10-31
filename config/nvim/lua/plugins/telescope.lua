local u = require('core.utils')

local telescope = require('telescope')
local actions = require('telescope.actions')
local trouble = require('trouble.providers.telescope')

telescope.setup({
  defaults = {
    prompt_prefix = '❯ ',
    selection_caret = '❯ ',
    layout_strategy = 'flex',
    layout_config = { flex = { preview_width = 0.7 } },
    file_ignore_patterns = { 'node_modules/.*' },
    mappings = {
      i = {
        ['<C-j>'] = actions.move_selection_next,
        ['<C-k>'] = actions.move_selection_previous,
        ['<C-t>'] = trouble.open_with_trouble,
      },
      n = {
        ['<C-c>'] = actions.close,
        ['<C-t>'] = trouble.open_with_trouble,
      },
    },
  },
})

if u.is_git_dir() == 0 then
  u.map('n', '<C-p>', ':lua require"telescope.builtin".git_files({show_untracked = true})<CR>')
else
  u.map('n', '<C-p>', ':Telescope find_files<CR>')
end

u.map('n', '<leader>fb', ':Telescope buffers<CR>')
u.map('n', '<leader>fh', ':Telescope help_tags<CR>')
u.map('n', '<leader>fo', ':Telescope oldfiles<CR>')
u.map('n', '<leader>fw', ':Telescope live_grep<CR>')
u.map('n', '<leader>co', ':Telescope colorscheme<CR>')
-- TODO: study if it's possible to write the command below like the ones above (it has params, unlike the others)
u.map(
  'n',
  '<leader>fd',
  ':lua require"telescope.builtin".git_files({cwd = "$HOME/dotfiles", show_untracked = true })<CR>'
)
u.map('n', '<leader>cw', ':lua require"telescope.builtin".grep_string({search = vim.fn.expand("<cword>") })<CR>')

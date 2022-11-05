local u = require('core.utils')

local km = require('core.keymaps')

local telescope = require('telescope')
local builtin = require('telescope.builtin')
local actions = require('telescope.actions')
local cmd = vim.api.nvim_create_user_command

-- local switch_to_tree_view = function(prompt_bufnr)
--   actions.close(prompt_bufnr)
--   vim.api.nvim_command(':NvimTreeToggle')
-- end

telescope.setup({
  defaults = {
    prompt_prefix = '❯ ',
    selection_caret = '❯ ',
    -- layout_strategy = 'vertical',
    layout_strategy = 'horizontal',
    layout_config = {
      vertical = { width = 0.9, height = 0.9 },
      horizontal = { width = 0.9, preview_width = 0.6, height = 0.9 },
    },
    prompt_position = 'top',
    file_ignore_patterns = { 'node_modules/.*' },
    mappings = {
      i = {
        -- ['<C-n>'] = switch_to_tree_view,
        ['<C-j>'] = actions.move_selection_next,
        ['<C-k>'] = actions.move_selection_previous,
        ['<C-p>'] = actions.close,
        ['<C-d>'] = actions.delete_buffer,
      },
      n = {
        -- ['<C-n>'] = switch_to_tree_view,
        ['<C-c>'] = actions.close,
        ['<C-p>'] = actions.close,
        ['<C-d>'] = actions.delete_buffer,
      },
    },
  },
  extensions = {
    emoji = {
      action = function(emoji)
        vim.api.nvim_put({ emoji.value }, 'c', false, true) -- insert when picked
      end,
    },
    bookmarks = {
      selected_browser = 'chrome',
    },
  },
  -- if you want to configure themes for individual pickers, refer to below:
  -- pickers = {
  --   live_grep = {
  --     theme = 'dropdown',
  --   },
  -- },
})

telescope.load_extension('fzf')
telescope.load_extension('emoji')
telescope.load_extension('bookmarks')
telescope.load_extension('harpoon')

-- MAPPINGS

-- note, the idea behind the 'tt' mapping is so that not every
-- builtin becomes yet another mapping. 'tt' and typing in the builtin
-- is less memory overload, fast enough, and easier to maintain
km.nnoremap('<leader>tt', builtin.builtin)

-- that being said, some super common builtins I'm fine with mapping
-- mappings for
km.nnoremap('<C-p>', u.smart_telescope_files)
km.nnoremap('<leader>do', function()
  builtin.git_files({ prompt_title = 'Dotfiles', cwd = '$HOME/dotfiles', show_untracked = true })
end)
km.nnoremap('<leader>cw', function()
  builtin.grep_string({ search = vim.fn.expand('<cword>') })
end)
km.nnoremap('<leader>co', builtin.resume) -- (c)ontinue
km.nnoremap('<leader>fw', builtin.live_grep) -- (f)ind in (w)orkspace
km.nnoremap('<leader>fb', builtin.current_buffer_fuzzy_find) -- (f)ind in (b)uffer

-- TODO: see if it's possible to add these extensions below as options when using the '<leader>t' mapping
km.nnoremap('<leader>teb', ':Telescope bookmarks<CR>')
km.nnoremap('<leader>tee', ':Telescope emoji<CR>')

local u = require('core.utils')

local km = require('core.keymaps')

local telescope = require('telescope')
local builtin = require('telescope.builtin')
local actions = require('telescope.actions')
local cmd = vim.api.nvim_create_user_command

local switch_to_tree_view = function(prompt_bufnr)
  actions.close(prompt_bufnr)
  vim.api.nvim_command(':NvimTreeToggle')
end

telescope.setup({
  defaults = {
    prompt_prefix = '❯ ',
    selection_caret = '❯ ',
    layout_strategy = 'horizontal',
    layout_config = { horizontal = { width = 0.9, preview_width = 0.6, height = 0.9 } },
    { 'nvim-telescope/telescope-github.nvim' },
    file_ignore_patterns = { 'node_modules/.*' },
    mappings = {
      i = {
        ['<C-n>'] = switch_to_tree_view,
        ['<C-j>'] = actions.move_selection_next,
        ['<C-k>'] = actions.move_selection_previous,
        ['<C-p>'] = actions.close,
        ['<C-d>'] = actions.delete_buffer,
      },
      n = {
        ['<C-n>'] = switch_to_tree_view,
        ['<C-c>'] = actions.close,
        ['<C-p>'] = actions.close,
        ['<C-d>'] = actions.delete_buffer,
      },
    },
  },
  extensions = {
    emoji = {
      action = function(emoji)
        -- emoji represents a table with the following properties:
        -- {name="", value="", cagegory="", description=""}
        vim.api.nvim_put({ emoji.value }, 'c', false, true) -- insert when picked
      end,
    },
    bookmarks = {
      selected_browser = 'chrome',
    },
  },
})

telescope.load_extension('fzf')
telescope.load_extension('emoji')
telescope.load_extension('bookmarks')

cmd('Rg', function(props)
  builtin.grep_string({ search = props.args })
end, { nargs = '*' })


-- MAPPINGS

-- note, the idea behind the 'tt' mapping is so that not every
-- builtin becomes yet another mapping. 'tt' and typing in the builtin
-- is less memory overload, fast enough, and easier to maintain
km.nnoremap(';t', builtin.builtin)

-- that being said, some super common builtins I'm fine with mapping
-- mappings for
km.nnoremap(';f', u.smart_telescope_files)
km.nnoremap(';d', function()
  builtin.git_files({ cwd = '$HOME/dotfiles', show_untracked = true })
end)
km.nnoremap(';cw', function()
  builtin.grep_string({ search = vim.fn.expand('<cword>') })
end)
km.nnoremap(';;', builtin.resume)
km.nnoremap(';b', builtin.buffers)
km.nnoremap(';cc', builtin.commands)
km.nnoremap(';ht', builtin.help_tags)
km.nnoremap(';g', builtin.live_grep)

-- TODO: see if it's possible to add these extensions below as options when using the ';t' mapping
km.nnoremap(';eb', ':Telescope bookmarks<CR>')
km.nnoremap(';ee', ':Telescope emoji<CR>')

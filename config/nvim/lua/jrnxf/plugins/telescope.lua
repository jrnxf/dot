local u = require('jrnxf.core.utils')
local telescope = require('telescope')
local conf = require('telescope.config').values
local finders = require('telescope.finders')
local make_entry = require('telescope.make_entry')
local pickers = require('telescope.pickers')
local scan = require('plenary.scandir')
local builtin = require('telescope.builtin')
local actions = require('telescope.actions')
local action_set = require('telescope.actions.set')
local action_state = require('telescope.actions.state')

local trouble = require('trouble.providers.telescope')

local lga_actions = require('telescope-live-grep-args.actions')

local path = require('plenary.path')
local os_sep = path.path.sep

local cmd = vim.api.nvim_create_user_command

cmd('Rg', function(props)
  builtin.grep_string({ search = props.args })
end, { nargs = '*' })

telescope.setup({
  defaults = {
    vimgrep_arguments = {
      'rg',
      -- telescope defaults
      '--color=never',
      '--no-heading',
      '--with-filename',
      '--line-number',
      '--column',
      '--smart-case',
      -- custom
      '--fixed-strings',
    },
    prompt_prefix = '❯ ',
    selection_caret = '❯ ',
    -- layout_strategy = 'vertical',
    layout_strategy = 'horizontal',
    layout_config = {
      vertical = { width = 0.9, height = 0.9, preview_height = 0.6 },
      horizontal = { width = 0.9, height = 0.9, preview_width = 0.6 },
    },
    prompt_position = 'top',
    file_ignore_patterns = { 'node_modules/.*' },
    mappings = {
      i = {
        ['<C-j>'] = actions.move_selection_next,
        ['<C-k>'] = actions.move_selection_previous,
        ['<C-p>'] = actions.close,
        ['<C-d>'] = actions.delete_buffer,
        ['<C-t>'] = trouble.open_with_trouble,
      },
      n = {
        ['<C-c>'] = actions.close,
        ['<C-p>'] = actions.close,
        ['<C-d>'] = actions.delete_buffer,
        ['<C-t>'] = trouble.open_with_trouble,
      },
    },
  },
  extensions = {
    emoji = {
      action = function(emoji)
        vim.api.nvim_put({ emoji.value }, 'c', false, true) -- insert when picked
      end,
    },
    bookmarks = { selected_browser = 'chrome' },
    live_grep_args = {
      auto_quoting = true, -- enable/disable auto-quoting
      -- define mappings, e.g.
      mappings = { -- extend mappings
        i = {
          -- ['<C-k>'] = lga_actions.quote_prompt(), -- conflicts with selection navigation
          ['<C-i>'] = lga_actions.quote_prompt({ postfix = ' --iglob ' }),
        },
      },
      -- ... also accepts theme settings, for example:
      -- theme = "dropdown", -- use dropdown theme
      -- theme = { }, -- use own theme spec
      -- layout_config = { mirror=true }, -- mirror preview pane
    },
  },
  -- if you want to configure themes for individual pickers, refer to below:
  -- pickers = { live_grep = { theme = 'dropdown' } },
})

telescope.load_extension('fzf')
telescope.load_extension('live_grep_args')
telescope.load_extension('emoji')
telescope.load_extension('bookmarks')
telescope.load_extension('harpoon')

-- custom pickers
local live_grep_in_folder = function(opts)
  opts = opts or {}
  local data = {}
  scan.scan_dir(vim.loop.cwd(), {
    hidden = opts.hidden,
    only_dirs = true,
    respect_gitignore = opts.respect_gitignore,
    on_insert = function(entry)
      table.insert(data, entry .. os_sep)
    end,
  })
  table.insert(data, 1, '.' .. os_sep)

  pickers
    .new(opts, {
      prompt_title = 'Select Folder',
      finder = finders.new_table({ results = data, entry_maker = make_entry.gen_from_file(opts) }),
      previewer = conf.file_previewer(opts),
      sorter = conf.file_sorter(opts),
      attach_mappings = function(prompt_bufnr)
        action_set.select:replace(function()
          local current_picker = action_state.get_current_picker(prompt_bufnr)
          local dirs = {}
          local selections = current_picker:get_multi_selection()
          if vim.tbl_isempty(selections) then
            table.insert(dirs, action_state.get_selected_entry().value)
          else
            for _, selection in ipairs(selections) do
              table.insert(dirs, selection.value)
            end
          end
          actions._close(prompt_bufnr, current_picker.initial_mode == 'insert')
          require('telescope.builtin').live_grep({ search_dirs = dirs })
        end)
        return true
      end,
    })
    :find()
end

-- colors.set_hl_from_table({
--   -- TelescopeTitle = { bg = palette.bg0, fg = palette.green.base },
--   TelescopeNormal = { bg = '#132325' },
--   TelescopeBorder = { bg = '#132325' },
-- })

-- MAPPINGS

-- NOTE: the idea behind the 't' mapping is so that not every
-- builtin becomes yet another mapping. 't' and typing in the builtin
-- is less memory overload, fast enough, and easier to maintain
nmap('<leader>t', function()
  builtin.builtin({ include_extensions = true })
end)

-- that being said, some super common builtins I'm fine with mapping
-- mappings for
nmap('<C-p>', u.smart_telescope_files)
nmap('<leader>do', function()
  builtin.git_files({ prompt_title = 'Dotfiles', cwd = '$HOME/dotfiles', show_untracked = true })
end)
nmap('<leader>cw', function()
  builtin.grep_string({ search = vim.fn.expand('<cword>') })
end)
nmap('<leader>co', builtin.commands) -- (com)mands
nmap('<leader>he', builtin.help_tags) -- (he)lp tags
nmap('<leader>re', builtin.resume) -- (re)sume
nmap('<leader>fw', builtin.live_grep) -- (f)ind in (w)orkspace
nmap('<leader>ff', live_grep_in_folder) -- (f)ind in (w)folder
nmap('<leader>fb', builtin.current_buffer_fuzzy_find) -- (f)ind in (b)uffer

return function()
  local telescope = require 'telescope'
  local actions = require 'telescope.actions'
  local trouble = require 'trouble.providers.telescope'

  telescope.setup {
    defaults = {
      prompt_prefix = '❯ ',
      selection_caret = '❯ ',
      layout_strategy = 'vertical',
      layout_config = { vertical = { preview_width = 0.5 } },
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
  }
end

return function()
  local nvim_tree = require 'nvim-tree'
  local map = require('nvim-tree.config').nvim_tree_callback

  nvim_tree.setup {
    auto_close = true,
    update_focused_file = {
      enable = true,
    },
    view = {
      auto_resize = true,
      mappings = {
        custom_only = false, -- `custom_only = false` will merge list of mappings with defaults
        list = {
          { key = '<C-R>', cb = map 'refresh' },
          { key = 'a', cb = map 'create' },
          { key = 'd', cb = map 'remove' },
          { key = 'h', cb = map 'close_node' },
          { key = 'I', cb = map 'toggle_ignored' },
          { key = 'l', cb = map 'edit' },
          { key = 'r', cb = map 'rename' },
          { key = 's', cb = map 'split' },
          { key = 'v', cb = map 'vsplit' },
          { key = 'Y', cb = map 'copy_path' },
          { key = 'y', cb = map 'copy_name' },
        },
      },
    },
  }
end

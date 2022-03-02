return function()
  local nvim_tree = require 'nvim-tree'

  nvim_tree.setup {
    auto_close = true,
    update_focused_file = {
      enable = true,
    },
    diagnostics = {
      enable = true,
    },
    view = {
      auto_resize = true,
      mappings = {
        custom_only = false, -- false means the list above will merge with defaults
        list = {
          { key = '<C-R>', action = 'refresh' },
          { key = 'a', action = 'create' },
          { key = 'd', action = 'remove' },
          { key = 'h', action = 'close_node' },
          { key = 'I', action = 'toggle_ignored' },
          { key = 'l', action = 'edit' },
          { key = 'r', action = 'rename' },
          { key = 's', action = 'split' },
          { key = 'v', action = 'vsplit' },
          { key = 'Y', action = 'copy_path' },
          { key = 'y', action = 'copy_name' },
        },
      },
    },
    -- actions = {
    --   open_file = {
    --     quit_on_open = true,
    --   },
    -- },
  }
end

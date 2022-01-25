return function()
    local ok, nvim_tree = safe_require 'nvim-tree'
    if not ok then
      return
    end
  
    local map = require('nvim-tree.config').nvim_tree_callback
  
    nvim_tree.setup {
      auto_close = true,
      git = {
          ignore = 1
      },
      open_on_setup = true,
      update_focused_file = {
        enable = true
      },
      view = {
        width = 35,
        side = 'left',
        auto_resize = true, -- resive after opening a file
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

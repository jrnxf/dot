vim.notify("after/plugin/nvim-tree")
local u = require('core.utils')

require('nvim-tree').setup({
  hijack_directories = {
    enable = false, -- when I open a dir i usually use telescope to find my file. I also hate seeing nvim-tree in full screen
  },
  update_focused_file = {
    enable = true,
  },
  diagnostics = {
    enable = true,
  },
  actions = {
    open_file = {
      -- quit_on_open = true,
      resize_window = true,
    },
  },
  view = {
    hide_root_folder = true,
    adaptive_size = true,
    -- float = {
    --   enable = true,
    -- },
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
})

u.map('n', '<C-n>', ':NvimTreeToggle<CR>')

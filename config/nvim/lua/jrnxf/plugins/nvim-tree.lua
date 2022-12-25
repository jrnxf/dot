local nt = require('nvim-tree')
local api = require('nvim-tree.api')

nt.setup({
  hijack_directories = {
    enable = false, -- don't auto open nvim_tree on directories
  },
  update_focused_file = {
    enable = true,
  },
  diagnostics = {
    enable = true,
  },
  actions = {
    open_file = {
      quit_on_open = true,
      resize_window = true,
    },
  },
  view = {
    -- hide_root_folder = true,
    adaptive_size = true,
    -- NOTE:
    -- @ref https://github.com/nvim-tree/nvim-tree.lua/pull/1538#issuecomment-1223314278
    -- logic to calculate dynanic, centered tree positioning
    -- float = {
    --   enable = true,
    --   -- NOTE: this makes it so that the vim input/select (via dressing) that steals focus doesn't close nvim-tree
    --   -- I can still <C-w> away from the float and have it not close, which is unfortunate, but I don't mentally
    --   -- think to even try that when in float mode
    --   quit_on_focus_loss = false,
    --   -- end NOTE
    --   open_win_config = function()
    --     local screen_w = vim.opt.columns:get()
    --     local screen_h = vim.opt.lines:get() - vim.opt.cmdheight:get()
    --     local _width = screen_w * 0.3
    --     local _height = screen_h * 0.8
    --     local width = math.floor(_width)
    --     local height = math.floor(_height)
    --     local center_y = ((vim.opt.lines:get() - _height) / 2) - vim.opt.cmdheight:get()
    --     local center_x = (screen_w - _width) / 2
    --     local layouts = {
    --       center = {
    --         anchor = 'NW',
    --         relative = 'editor',
    --         border = 'rounded',
    --         row = center_y,
    --         col = center_x,
    --         width = width,
    --         height = height,
    --       },
    --     }
    --     return layouts.center
    --   end,
    -- },
    -- width = function()
    --   return math.floor(vim.opt.columns:get() * 0.3)
    -- end,
    -- end NOTE
    mappings = {
      custom_only = false, -- false means the list above will merge with defaults
      list = {
        { key = '<C-c>', action = 'close' },
        -- { key = '<C-w>', action = 'close' },
        { key = '<C-r>', action = 'refresh' },
        {
          key = '<CR>',
          action = 'cd_or_open', -- name not relevant, made up by me
          action_cb = function(node)
            -- if the node is the parent node (name == "..") or a directory
            if node.name == '..' or node.fs_stat.type == 'directory' then
              api.tree.change_root_to_node()
            elseif node.fs_stat.type == 'file' then
              api.node.open.edit()
            end
          end,
        },
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

nmap('<leader>tt', ':NvimTreeToggle<CR>', { silent = true })

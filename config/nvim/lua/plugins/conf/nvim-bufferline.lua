return function()
  local bufferline = require 'bufferline'

  bufferline.setup {
    options = {
      offsets = {
        {
          filetype = 'NvimTree',
        },
      },
      show_buffer_icons = false,
      show_buffer_close_icons = false,
      show_close_icon = false,
    },
  }
end

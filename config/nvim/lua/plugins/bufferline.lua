require('bufferline').setup {
  options = {
    offsets = {
      {
        text = '',
        filetype = 'NvimTree',
        -- padding = 1 fixes the annoying issue where bufferline seems to
        -- overlap with NvimTree, finally making them perfectly aligned
        padding = 1,
      },
    },
    show_buffer_icons = true,
    show_buffer_close_icons = true,
    show_close_icon = true,
  },
}

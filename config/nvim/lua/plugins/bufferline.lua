local km = require('core.keymaps')

require('bufferline').setup({
  options = {
    -- mode = 'tabs', -- useful if you prefer to bufferline to actually operate on tabs
    offsets = {
      {
        text = '',
        filetype = 'NvimTree',
        padding = 1,
      },
    },
    show_buffer_icons = true,
  },
})

km.nnoremap('<Tab>', ':BufferLineCycleNext<CR>', { noremap = true })
km.nnoremap('<S-Tab>', ':BufferLineCyclePrev<CR>', { noremap = true })

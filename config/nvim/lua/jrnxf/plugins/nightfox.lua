local palette = require('nightfox.palette').load('terafox')
_G.colorscheme_palette = vim.inspect(palette) -- for convenience (:lua print(palette))

require('nightfox').setup({
  palettes = {
    terafox = {
      bg1 = palette.bg0, -- makes the same as bg1
    },
  },
})

vim.cmd('colorscheme terafox')

local terafox = require('nightfox.palette').load('terafox')
local nordfox = require('nightfox.palette').load('nordfox')
local nightfox = require('nightfox.palette').load('nightfox')
_G.colorscheme_palette = vim.inspect(terafox) -- for convenience (:lua print(palette))

require('nightfox').setup({
  palettes = {
    terafox = {
      bg1 = terafox.bg0, -- makes the same as bg1
    },
    nordfox = {
      bg1 = nordfox.bg0, -- makes the same as bg1
    },
    nightfox = {
      bg1 = nightfox.bg0, -- makes the same as bg1
    },
  },
})

vim.cmd('colorscheme terafox')

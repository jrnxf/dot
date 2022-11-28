local palette = require('nightfox.palette').load('terafox')

-- P(palette)
require('nightfox').setup({
  palettes = {
    terafox = {
      bg1 = palette.bg0, -- makes the same as bg1
    },
  },
  groups = {
    terafox = {
      FloatBorder = { bg = palette.bg0, fg = '#688b89' },
      FloatTitle = { bg = palette.bg0, fg = '#7aa4a1' },
      CursorLine = { bg = '#1a2e32' }, -- this is a slight mod from terafox (TODO: change terafox palette instead of doing this)
      VertSplit = { fg = '#152528' },
      StatusLineNC = { bg = '#152528', fg = '#7aa4a1' }, -- status line none current
      StatusLine = { bg = '#152528' }, -- this must be style different that NC otherwise vim will use ^^^^^^ to differentiate
    },
  },
})

vim.cmd('colorscheme terafox')

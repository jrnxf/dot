local leap = require('leap')

leap.add_default_mappings()
vim.api.nvim_set_hl(0, 'LeapLabelPrimary', {
  bg = '#5E81AC',
  fg = 'white',
  bold = true,
})
vim.api.nvim_set_hl(0, 'LeapLabelSecondary', {
  bg = '#BF616A',
  fg = 'white',
  bold = true,
})

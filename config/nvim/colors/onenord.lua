vim.notify('colors/onenord')
local colors = {
  bg = '#191c23',
  active_line = '#262C37',
}

require('onenord').setup({
  custom_highlights = {
    CursorLine = {
      bg = colors.active_line,
    },
  },
  custom_colors = {
    bg = colors.bg,
    active = colors.bg,
    float = colors.active_line,
  },
})

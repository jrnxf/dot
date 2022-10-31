local colors = {
  primary = '#191c23',
  secondary = '#1e212a',
}

require('onenord').setup({
  custom_highlights = {
    CursorLine = {
      bg = colors.secondary,
    },
  },
  custom_colors = {
    bg = colors.primary,
    active = colors.secondary,
  },
})

local colors = {
  primary = '#151a23',
  secondary = '#191f29',
}

-- paste in command mode to see available colors
-- lua print(vim.inspect(require("onenord.colors").load()))

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

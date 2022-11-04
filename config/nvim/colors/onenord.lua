local colors = {
  primary = '#191c23',
  secondary = '#1e212a',
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

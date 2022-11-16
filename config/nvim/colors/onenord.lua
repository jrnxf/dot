local colors = {
  primary = '#151a23',
  secondary = '#191f29',
  tertiary = '#1d242f',
}

-- paste in command mode to see available colors
-- lua print(vim.inspect(require("onenord.colors").load()))

require('onenord').setup({
  custom_highlights = {
    CursorLine = { -- this is really tough to see
      bg = colors.tertiary,
    },
  },
  custom_colors = {
    bg = colors.primary,
    active = colors.secondary,
  },
})

return function()
  local ok, lualine = safe_require 'lualine'
  if not ok then
    return
  end

  lualine.setup {
    options = {
      theme = 'onenord'
    },
  }
end

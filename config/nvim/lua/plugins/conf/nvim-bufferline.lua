return function()
  local ok, bufferline = safe_require 'bufferline'
  if not ok then
    return
  end

  bufferline.setup {
    options = {
      offsets = { { filetype = 'NvimTree', highlight="Directory" } },
      show_buffer_close_icons = false,
      show_close_icon = false,
      show_tab_indicators = true,
    },
  }
end

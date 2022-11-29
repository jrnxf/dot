local Popup = require('nui.popup')
local event = require('nui.utils.autocmd').event

local print_variable = function()
  vim.ui.input({ prompt = 'variable' }, function(input)
    local popup = Popup({
      enter = true,
      focusable = true,
      border = {
        padding = { 2, 2 },
        style = 'rounded',
        text = {
          top = (' %s '):format(input),
          top_align = 'center',
        },
      },
      win_options = {
        winhighlight = 'Normal:Normal,FloatBorder:FloatBorder',
      },
      position = '50%',
      size = {
        width = '80%',
        height = '60%',
      },
    })
    local highlights = vim.api.nvim_exec(input, true)

    local lines = {}
    for s in highlights:gmatch('[^\n]+') do
      table.insert(lines, s)
    end
    vim.api.nvim_buf_set_lines(popup.bufnr, 0, -1, false, lines)
    -- mount/open the component
    popup:mount()

    -- unmount component when cursor leaves buffer
    popup:on(event.BufLeave, function()
      popup:unmount()
    end)
    popup:map('n', '<C-c>', function()
      popup:unmount()
    end, { noremap = true })
  end)
end

nmap('<leader>pv', print_variable) -- exec current file

local fmt = string.format

-- Ui highlight color groups
--
-- This file contains the highlight group definitions for both:
--   - feline (statusline)
--   - tabby (tabline)
--
-- The colors are pulled from the current applied colorscheme.  This requires
-- that your colorscheme defines the highlight groups queried as well as
-- neovim's vim.g.terminal_color_* (s).
--
-- There is an autocmd that regenerates the highlight group colors on
-- colorscheme change.

local M = {}

function M.set_highlights(groups)
  local lines = {}
  for group, opts in pairs(groups) do
    if opts.link then
      table.insert(lines, fmt('highlight! link %s %s', group, opts.link))
    else
      table.insert(
        lines,
        fmt(
          'highlight %s guifg=%s guibg=%s gui=%s guisp=%s',
          group,
          opts.fg or 'NONE',
          opts.bg or 'NONE',
          opts.style or 'NONE',
          opts.sp or 'NONE'
        )
      )
    end
  end
  vim.cmd(table.concat(lines, ' | '))
end

local function get_highlight(name)
  local hl = vim.api.nvim_get_hl_by_name(name, true)
  if hl.link then
    return get_highlight(hl.link)
  end

  local hex = function(n)
    if n then
      return string.format('#%06x', n)
    end
  end

  local names = { 'underline', 'undercurl', 'bold', 'italic', 'reverse' }
  local styles = {}
  for _, n in ipairs(names) do
    if hl[n] then
      table.insert(styles, n)
    end
  end

  return {
    fg = hex(hl.foreground),
    bg = hex(hl.background),
    sp = hex(hl.special),
    style = #styles > 0 and table.concat(styles, ',') or 'NONE',
  }
end

function M.set_hl_from_table(hl_group)
  for hl_name, opts in pairs(hl_group or {}) do
    vim.api.nvim_set_hl(0, hl_name, opts)
  end
end

function M.generate_pallet_from_colorscheme()
  -- stylua: ignore
  local color_map = {
    black   = { index = 0, default = "#393b44" },
    red     = { index = 1, default = "#c94f6d" },
    green   = { index = 2, default = "#81b29a" },
    yellow  = { index = 3, default = "#dbc074" },
    blue    = { index = 4, default = "#719cd6" },
    magenta = { index = 5, default = "#9d79d6" },
    cyan    = { index = 6, default = "#63cdcf" },
    white   = { index = 7, default = "#dfdfe0" },
  }

  local diagnostic_map = {
    hint = { hl = 'DiagnosticHint', default = color_map.green.default },
    info = { hl = 'DiagnosticInfo', default = color_map.blue.default },
    warn = { hl = 'DiagnosticWarn', default = color_map.yellow.default },
    error = { hl = 'DiagnosticError', default = color_map.red.default },
  }

  local palette = {}
  for name, value in pairs(color_map) do
    local global_name = 'terminal_color_' .. value.index
    palette[name] = vim.g[global_name] and vim.g[global_name] or value.default
  end

  for name, value in pairs(diagnostic_map) do
    palette[name] = get_highlight(value.hl).fg or value.default
  end

  local cursorline = get_highlight('CursorLine')
  palette.bgalt = cursorline.bg
  palette.sl = get_highlight('StatusLine')
  palette.tab = get_highlight('TabLine')
  palette.sel = get_highlight('PmenuSel')
  palette.fill = get_highlight('TabLineFill')

  _G.palette = vim.inspect(palette)
  return palette
end

return M

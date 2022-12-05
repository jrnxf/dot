local colors_lib = require('jrnxf.lib.colors')
-- not a fan of these colors but keeping around so I remember to come back to
-- find better colors
-- -- gray
-- vim.cmd([[ highlight! CmpItemAbbrDeprecated guibg=NONE gui=strikethrough guifg=#808080 ]])
-- -- blue
-- vim.cmd([[ highlight! CmpItemAbbrMatch guibg=NONE guifg=#569CD6 ]])
-- vim.cmd([[ highlight! link CmpItemAbbrMatchFuzzy CmpItemAbbrMatch ]])
-- -- light blue
-- vim.cmd([[ highlight! CmpItemKindVariable guibg=NONE guifg=#9CDCFE ]])
-- vim.cmd([[ highlight! link CmpItemKindInterface CmpItemKindVariable ]])
-- vim.cmd([[ highlight! link CmpItemKindText CmpItemKindVariable ]])
-- -- pink
-- vim.cmd([[ highlight! CmpItemKindFunction guibg=NONE guifg=#C586C0 ]])
-- vim.cmd([[ highlight! link CmpItemKindMethod CmpItemKindFunction ]])
-- -- front
-- vim.cmd([[ highlight! CmpItemKindKeyword guibg=NONE guifg=#D4D4D4 ]])
-- vim.cmd([[ highlight! link CmpItemKindProperty CmpItemKindKeyword ]])
-- vim.cmd([[ highlight! link CmpItemKindUnit CmpItemKindKeyword ]])

local function generate_colors(args)
  if args.match == 'terafox' then
    local terafox = require('nightfox.palette').load('terafox')
    local groups = {
      -- general
      -- Search = { fg = 'white', bg = terafox.magenta.dim },
      -- IncSearch = { fg = 'white', bg = terafox.yellow.dim },
      DiagnosticSignInfo = { link = 'FloatBorder' }, -- used heavily by noice
      NullLsInfoBorder = { link = 'NormalFloatBorder' }, -- TODO pr this - it's weird that they used NormalFloat here and not NormalFloatBorder
      NullLsInfoTitle = { link = 'Title' },
      VertSplit = { fg = '#152528' },
      NormalFloat = { bg = terafox.bg0 },
      NormalFloatBorder = { fg = terafox.green.dim },
      MasonHeader = { bg = terafox.green.dim },
      MasonHeaderSecondary = { bg = terafox.green.dim },
      MasonHighlightBlock = { bg = terafox.green.dim },
      MasonHighlightBlockBold = { bg = terafox.green.dim },
      Substitute = { bg = terafox.magenta.dim, fg = 'white' },
      FloatBorder = { fg = terafox.green.dim },
      TelescopeBorder = { fg = terafox.green.dim },
      PMenu = { bg = terafox.bg0 },
      PMenuBorder = { fg = terafox.green.dim },
      LspInfoBorder = { fg = terafox.green.dim },
      CmpPmenuBorder = { fg = terafox.green.dim },
      StatusLineNC = { bg = '#152528', fg = '#7aa4a1' }, -- status line none current
      StatusLine = { bg = '#152528' }, -- this must be style different that NC otherwise vim will use ^^^^^^ to differentiate
    }

    colors_lib.set_highlights(groups)
  end

  -- 181825
  local pal = colors_lib.generate_pallet_from_colorscheme()

  -- stylua: ignore
  local sl_colors = {
    Black   = { fg = pal.black, bg = pal.white },
    Red     = { fg = pal.red, bg = pal.sl.bg },
    Green   = { fg = pal.green, bg = pal.sl.bg },
    Yellow  = { fg = pal.yellow, bg = pal.sl.bg },
    Blue    = { fg = pal.blue, bg = pal.sl.bg },
    Magenta = { fg = pal.magenta, bg = pal.sl.bg },
    Cyan    = { fg = pal.cyan, bg = pal.sl.bg },
    White   = { fg = pal.white, bg = pal.black },
  }

  local colors = {}
  for name, value in pairs(sl_colors) do
    colors['Jrnxf' .. name] = { fg = value.fg, bg = value.bg, style = 'bold' }
    colors['JrnxfRv' .. name] = { fg = value.bg, bg = value.fg, style = 'bold' }
  end

  local status = vim.o.background == 'dark' and { fg = pal.black, bg = pal.white } or { fg = pal.white, bg = pal.black }

  local groups = {
    -- statusline
    JrnxfSLHint = { fg = pal.sl.bg, bg = pal.hint, style = 'bold' },
    JrnxfSLInfo = { fg = pal.sl.bg, bg = pal.info, style = 'bold' },
    JrnxfSLWarn = { fg = pal.sl.bg, bg = pal.warn, style = 'bold' },
    JrnxfSLError = { fg = pal.sl.bg, bg = pal.error, style = 'bold' },
    JrnxfSLStatus = { fg = status.fg, bg = status.bg, style = 'bold' },

    JrnxfSLFtHint = { fg = pal.bgalt, bg = pal.hint },
    JrnxfSLHintInfo = { fg = pal.hint, bg = pal.info },
    JrnxfSLInfoWarn = { fg = pal.info, bg = pal.warn },
    JrnxfSLWarnError = { fg = pal.warn, bg = pal.error },
    JrnxfSLErrorStatus = { fg = pal.error, bg = status.bg },
    JrnxfSLStatusBg = { fg = status.bg, bg = pal.sl.bg },

    JrnxfSLAlt = { fg = status.bg, bg = pal.bgalt },
    JrnxfSLAltSep = { fg = pal.sl.bg, bg = pal.bgalt },
    JrnxfSLGitBranch = { fg = pal.yellow, bg = pal.sl.bg },

    -- tabline
    JrnxfTLHead = { fg = pal.fill.bg, bg = pal.cyan },
    JrnxfTLHeadSep = { fg = pal.cyan, bg = pal.fill.bg },
    JrnxfTLActive = { fg = pal.sel.fg, bg = pal.sel.bg, style = 'bold' },
    JrnxfTLActiveSep = { fg = pal.sel.bg, bg = pal.fill.bg },
    JrnxfTLBoldLine = { fg = pal.tab.fg, bg = pal.tab.bg, style = 'bold' },
    JrnxfTLLineSep = { fg = pal.tab.bg, bg = pal.fill.bg },
  }

  colors_lib.set_highlights(vim.tbl_extend('force', colors, groups))
end

-- Define autocmd that generates the highlight groups from the new colorscheme
-- Then reset the highlights for feline
augroup('JrnxfUiColorschemeReload', {
  event = { 'SessionLoadPost', 'ColorScheme' },
  exec = generate_colors,
})

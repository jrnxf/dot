require('jrnxf.lib.colors')
local u = require('jrnxf.plugins.feline.util')
-- local noice = require('noice.api.status')
-- local ns = require('noice').api.status

local fmt = string.format

-- "┃", "█", "", "", "", "", "", "", "●"

local get_diag = function(str)
  local diagnostics = vim.diagnostic.get(0, { severity = vim.diagnostic.severity[str] })
  local count = #diagnostics

  return (count > 0) and ' ' .. count .. ' ' or ''
end

local function vi_mode_hl()
  return u.vi.colors[vim.fn.mode()] or ''
end

local function vi_sep_hl()
  return u.vi.sep[vim.fn.mode()] or ''
end

local function file_info()
  local list = {}
  if vim.bo.readonly then
    table.insert(list, '🔒')
  end

  if vim.bo.modified then
    table.insert(list, '[+]')
  end

  table.insert(list, vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ':~:.'))

  return table.concat(list, ' ')
end

local c = {
  vimode = {
    provider = function()
      return string.format(' %s ', u.vi.text[vim.fn.mode()])
    end,
    hl = vi_mode_hl,
    right_sep = { str = ' ', hl = vi_sep_hl },
  },
  gitbranch = {
    provider = 'git_branch',
    icon = '  ',
    hl = 'JrnxfSLGitBranch',
    right_sep = { str = ' ', hl = 'JrnxfSLGitBranch' },
    enabled = function()
      return vim.b.gitsigns_status_dict ~= nil
    end,
  },
  file_type = {
    provider = function()
      return fmt(' %s ', vim.bo.filetype:upper())
    end,
    hl = 'JrnxfSLAlt',
  },
  fileinfo = {
    provider = { name = 'file_info', opts = { type = 'relative' } },
    hl = 'JrnxfSLAlt',
    left_sep = { str = ' ', hl = 'JrnxfSLAltSep' },
    right_sep = { str = ' ', hl = 'JrnxfSLAltSep' },
  },
  -- makes everything super laggy :/
  -- noice_mode = {
  --   -- provider = require('noice').api.status.mode.get_hl,
  --   provider = function()
  --     -- vim.notify('here')
  --     -- -- local foo = ns.mode.get
  --     -- -- put(foo)
  --     -- return 'noice'
  --   end,
  --   -- condition = true,
  --   condition = require('noice').api.status.mode.has,
  -- },
  file_enc = {
    provider = function()
      local os = u.icons[vim.bo.fileformat] or ''
      return fmt(' %s %s ', os, vim.bo.fileencoding)
    end,
    hl = 'StatusLine',
    left_sep = { str = u.icons.left_filled, hl = 'JrnxfSLAltSep' },
  },
  cur_position = {
    provider = function()
      -- TODO: What about 4+ diget line numbers?
      return fmt(' %d:%d ', unpack(vim.api.nvim_win_get_cursor(0)))
    end,
    hl = vi_mode_hl,
    left_sep = { str = u.icons.left_filled, hl = vi_sep_hl },
  },
  cur_percent = {
    provider = function()
      return ' ' .. require('feline.providers.cursor').line_percentage() .. '  '
    end,
    hl = vi_mode_hl,
    left_sep = { str = u.icons.left, hl = vi_mode_hl },
  },
  default = { -- needed to pass the parent StatusLine hl group to right hand side
    provider = '',
    hl = 'StatusLine',
  },
  lsp_status = {
    provider = function()
      return vim.tbl_count(vim.lsp.buf_get_clients(0)) == 0 and '' or ' ◦ '
    end,
    hl = 'JrnxfSLStatus',
    left_sep = { str = '', hl = 'JrnxfSLStatusBg', always_visible = true },
    right_sep = { str = '', hl = 'JrnxfSLErrorStatus', always_visible = true },
  },
  lsp_error = {
    provider = function()
      return get_diag('ERROR')
    end,
    hl = 'JrnxfSLError',
    right_sep = { str = '', hl = 'JrnxfSLWarnError', always_visible = true },
  },
  lsp_warn = {
    provider = function()
      return get_diag('WARN')
    end,
    hl = 'JrnxfSLWarn',
    right_sep = { str = '', hl = 'JrnxfSLInfoWarn', always_visible = true },
  },
  lsp_info = {
    provider = function()
      return get_diag('INFO')
    end,
    hl = 'JrnxfSLInfo',
    right_sep = { str = '', hl = 'JrnxfSLHintInfo', always_visible = true },
  },
  lsp_hint = {
    provider = function()
      return get_diag('HINT')
    end,
    hl = 'JrnxfSLHint',
    right_sep = { str = '', hl = 'JrnxfSLFtHint', always_visible = true },
  },

  in_fileinfo = {
    provider = 'file_info',
    hl = 'StatusLine',
  },
  in_position = {
    provider = 'position',
    hl = 'StatusLine',
  },
  file_winbar = {
    provider = file_info,
    hl = 'WinBar',
  },
}

local active = {
  { -- left
    c.vimode,
    c.gitbranch,
    c.fileinfo,
    c.default, -- must be last
  },
  { -- right
    c.lsp_status,
    c.lsp_error,
    c.lsp_warn,
    c.lsp_info,
    c.lsp_hint,
    c.file_type,
    c.file_enc,
    -- c.noice_mode,
    c.cur_position,
    c.cur_percent,
  },
}

local inactive = {
  { c.in_fileinfo }, -- left
  { c.in_position }, -- right
}

require('feline').setup({
  components = { active = active, inactive = inactive },
  highlight_reset_triggers = {},
  force_inactive = {
    filetypes = {
      -- note: with laststatus set to 3, i always want stats at the bottom
      -- 'NvimTree',
      -- 'packer',
      -- 'dap-repl',
      -- 'dapui_scopes',
      -- 'dapui_stacks',
      -- 'dapui_watches',
      -- 'dapui_repl',
      -- 'LspTrouble',
      -- 'qf',
      -- 'help',
    },
    buftypes = { 'terminal' },
    bufnames = {},
  },
  disable = {
    filetypes = {
      'dashboard',
      'startify',
    },
  },
})

-- require('feline').winbar.setup({
--   components = {
--     active = {
--       {},
--       {
--         c.file_winbar,
--       },
--     },
--   },
-- })

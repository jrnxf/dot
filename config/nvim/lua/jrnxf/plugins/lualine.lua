require('lualine').setup({
  options = {
    icons_enabled = true,
    globalstatus = true,
    section_separators = { left = '', right = '' },
    component_separators = { left = '', right = '' },
    -- section_separators = { left = '', right = '' },
    -- component_separators = { left = '', right = '' },
    disabled_filetypes = {
      'packer', -- not necessary when in float mode but still keeping this around
      'NvimTree',
    },
  },
  sections = {
    lualine_a = { 'mode' },
    lualine_b = { 'branch' },
    lualine_c = {
      {
        'filename',
        file_status = true, -- displays file status (readonly status, modified status)
        path = 0, -- 0 = just filename, 1 = relative path, 2 = absolute path
      },
    },

    -- I like lualines a,b,c,y,z defaults
    -- lualine_x = {
    --   {
    --     require('noice').api.status.message.get_hl,
    --     cond = require('noice').api.status.message.has,
    --   },
    --   {
    --     require('noice').api.status.command.get,
    --     cond = require('noice').api.status.command.has,
    --     color = { fg = '#ff9e64' },
    --   },
    --   {
    --     require('noice').api.status.mode.get,
    --     cond = require('noice').api.status.mode.has,
    --     color = { fg = '#ff9e64' },
    --   },
    --   {
    --     require('noice').api.status.search.get,
    --     cond = require('noice').api.status.search.has,
    --     color = { fg = '#ff9e64' },
    --   },
    --   -- {
    --   --   'diagnostics',
    --   --   sources = { 'nvim_diagnostic' },
    --   --   symbols = { error = ' ', warn = ' ', info = ' ', hint = ' ' },
    --   -- },
    --   -- -- 'encoding',
    --   -- 'filetype',
    -- },
    -- lualine_y = { 'progress' },
    -- lualine_z = { 'location' },
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {
      {
        'filename',
        file_status = true, -- displays file status (readonly status, modified status)
        path = 1, -- 0 = just filename, 1 = relative path, 2 = absolute path
      },
    },
    lualine_x = { 'location' },
    lualine_y = {},
    lualine_z = {},
  },
  winbar = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = { 'mode' },
    lualine_x = { 'filename' },
    lualine_y = {},
    lualine_z = {},
  },
  tabline = {},
  extensions = { 'fugitive' },
})

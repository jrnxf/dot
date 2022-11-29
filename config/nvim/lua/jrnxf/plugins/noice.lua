require('noice').setup({
  lsp = {
    -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
    override = {
      ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
      ['vim.lsp.util.stylize_markdown'] = true,
      ['cmp.entry.get_documentation'] = true,
    },
  },
  -- you can enable a preset for easier configuration
  presets = {
    bottom_search = true, -- use a classic bottom cmdline for search
    command_palette = false, -- position the cmdline and popupmenu together
    long_message_to_split = true, -- long messages will be sent to a split
    inc_rename = true, -- enables an input dialog for inc-rename.nvim (which I don't use)
    -- lsp_doc_border = true, -- add a border to hover docs and signature help
    lsp_doc_border = true, -- add a border to hover docs and signature help
  },
  -- cmdline = {
  --   view = 'cmdline',
  -- },
  notify = {
    view = 'mini',
  },
  messages = {
    view = 'mini',
    view_search = false, --  "virtualtext", -- view for search count messages. Set to `false` to disable
  },
  views = {
    cmdline_popup = {
      position = {
        row = '50%',
        col = '50%',
      },
      win_options = {
        winhighlight = { Normal = 'Normal', FloatBorder = 'FloatBorder', NoiceCmdlinePopupBorder = 'FloatBorder' },
      },
    },
    popupmenu = {
      relative = 'editor',
      align = 'center',
      position = {
        row = '50%',
        col = '50%',
      },
      size = {
        width = 60,
        height = 10,
      },
      border = {
        style = 'rounded',
        padding = { 0, 1 },
      },
      win_options = {
        winhighlight = { Normal = 'Normal', FloatBorder = 'FloatBorder' },
      },
    },
    cmdline_output = {
      view = 'popup',
      enter = true,
      close = {
        keys = { '<C-c', 'esc' },
      },
    },
    messages = {
      view = 'popup',
      enter = true,
    },
  },
})

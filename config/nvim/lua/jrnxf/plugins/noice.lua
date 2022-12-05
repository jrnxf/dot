require('noice').setup({
  lsp = {
    -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
    override = {
      ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
      ['vim.lsp.util.stylize_markdown'] = true,
      ['cmp.entry.get_documentation'] = true,
    },
  },
  presets = {
    bottom_search = true, -- use a classic bottom cmdline for search
    long_message_to_split = false, -- long messages will be sent to a split
    inc_rename = true, -- enables an input dialog for inc-rename.nvim (which I don't use)
    lsp_doc_border = true, -- add a border to hover docs and signature help
    -- command_palette = false, -- position the cmdline and popupmenu together
    -- cmdline_output_to_split = true,
    command_palette = {
      views = {
        cmdline_popup = {
          position = {
            row = 20,
            col = '50%',
          },
          size = {
            min_width = 60,
            width = 'auto',
            height = 'auto',
          },
        },
        popupmenu = {
          relative = 'editor',
          position = {
            row = 23,
            col = '50%',
          },
          size = {
            width = 60,
            height = 'auto',
            max_height = 15,
          },
          border = {
            style = 'rounded',
            padding = { 0, 1 },
          },
          win_options = {
            winhighlight = { Normal = 'Normal', FloatBorder = 'NoiceCmdlinePopupBorder' },
          },
        },
      },
    },
  },
  -- notify = { view = 'mini' },
  messages = { view_search = 'mini' },
  -- cmdline = {
  --   -- view = 'cmdline',
  --   format = {
  --     conceal = false,
  --     -- conceal: (default=true) This will hide the text in the cmdline that matches the pattern.
  --     -- view: (default is cmdline view)
  --     -- opts: any options passed to the view
  --     -- icon_hl_group: optional hl_group for the icon
  --     -- title: set to anything or empty string to hide
  --     cmdline = { icon = '>' },
  --     search_down = { icon = '🔍⌄' },
  --     search_up = { icon = '🔍⌃' },
  --     filter = { icon = '$' },
  --     lua = { icon = '☾' },
  --     help = { icon = '?' },
  --   },
  -- },
  -- redirect = {
  --   view = 'popup',
  --   filter = { event = 'msg_show' },
  -- },
  popupmenu = {
    enabled = true, -- enables the Noice popupmenu UI
    ---@type 'nui'|'cmp'
    backend = 'nui', -- backend to use to show regular cmdline completions
    ---@type NoicePopupmenuItemKind|false
    -- Icons for completion item kinds (see defaults at noice.config.icons.kinds)
    kind_icons = {}, -- set to `false` to disable icons
  },
  views = {
    -- cmdline_popup = {
    --   position = { row = '50%', col = '50%' },
    --   win_options = {
    --     winhighlight = { Normal = 'Normal', FloatBorder = 'FloatBorder', NoiceCmdlinePopupBorder = 'FloatBorder' },
    --   },
    -- },
    -- popupmenu = {
    --   relative = 'editor',
    --   align = 'center',
    --   position = { row = '50%', col = '50%' },
    --   size = { width = 60, height = 10 },
    --   border = { style = 'rounded', padding = { 0, 1 } },
    --   win_options = { winhighlight = { Normal = 'Normal', FloatBorder = 'FloatBorder' } },
    -- },
    cmdline_output = {
      view = 'popup',
      enter = true,
      close = { keys = { '<C-c', 'esc' } },
    },
    messages = { view = 'popup', enter = true },
  },
  -- commands = {
  --   commands = {
  --     all = {
  --       -- options for the message history that you get with `:Noice`
  --       view = 'split',
  --       opts = { enter = true, format = 'details' },
  --       filter = {},
  --     },
  --   },
  -- },
  routes = {
    {
      view = 'notify',
      filter = { event = 'msg_showmode' }, -- so I can see macros
    },
  },
})

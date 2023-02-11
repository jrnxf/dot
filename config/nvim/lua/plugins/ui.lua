return {
  {
    "folke/noice.nvim",
    -- enabled = false,
    event = "VeryLazy",
    opts = {
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
        },
      },
      cmdline = {
        view = "cmdline",
      },
      messages = {
        view = "mini",
        view_error = "mini",
        view_warn = "mini",
      },
      presets = {
        bottom_search = false,
        command_palette = false,
        long_message_to_split = true,
        lsp_doc_border = true, -- add a border to hover docs and signature help
      },
    },
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    opts = {
      char = "▏",
      filetype_exclude = { "help", "alpha", "dashboard", "neo-tree", "Trouble", "lazy" },
      show_trailing_blankline_indent = false,
      show_current_context = false,
    },
  },
  {
    "akinsho/bufferline.nvim",
    enabled = false,
  },
  { "norcalli/nvim-colorizer.lua" },
  {
    -- "kdheepak/tabline.nvim",
    "keklleo/tabline.nvim",
    branch = "change-show-tabs-always",
    lazy = false,
    opts = function()
      vim.cmd([[
        set guioptions-=e " Use showtabline in gui vim
        set sessionoptions+=tabpages,globals " store tabpages and globals in session
      ]])

      return {
        -- Defaults configuration options
        enable = true,
        options = {
          -- If lualine is installed tabline will use separators configured in lualine by default.
          -- These options can be used to override those settings.
          component_separators = { "", "" },
          section_separators = { "", "" },
          max_bufferline_percent = 66, -- set to nil by default, and it uses vim.o.columns * 2/3
          show_tabs_always = true, -- this shows tabs only when there are more than one tab or if the first tab is named
          show_devicons = true, -- this shows devicons in buffer section
          colored = true,
          show_bufnr = false, -- this appends [bufnr] to buffer section,
          tabline_show_last_separator = true,
          show_filename_only = true, -- shows base filename only instead of relative path in filename
          modified_icon = "+ ", -- change the default modified icon
          modified_italic = true, -- set to true by default; this determines whether the filename turns italic if modified
          -- show_tabs_only = true, -- this shows only tabs instead of tabs + buffers
          show_tabline_buffers = 2, -- this shows buffer names (the left section of the tabline) always, when there is more than one buffer, or never
          show_tabline_tabs = 1, -- this shows tab names (the right section of the tabline) always, when there is more than one or a named tab, or never
        },
      }
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "keklleo/tabline.nvim" },
    event = "VeryLazy",
    -- @credit https://github.com/Strazil001/Nvim/blob/main/after/plugin/lualine.lua
    config = function()
      local terafox = require("nightfox.palette").load("terafox")
      local theme = {
        normal = {
          a = { fg = terafox.white.dim, bg = terafox.bg3 },
          b = { fg = terafox.white.dim, bg = terafox.bg2 },
          c = { fg = terafox.white.base, bg = terafox.bg0 },
          z = { fg = terafox.white.base, bg = terafox.bg0 },
        },
        insert = { a = { fg = terafox.black.dim, bg = terafox.yellow.bright } },
        visual = { a = { fg = terafox.black.dim, bg = "#986aa9" } },
        replace = { a = { fg = terafox.black.dim, bg = terafox.blue.bright } },
        command = { a = { fg = terafox.black.dim, bg = terafox.red.bright } },
      }

      local space = {
        function()
          return " "
        end,
        color = { bg = terafox.bg0, fg = terafox.bg0 },
      }

      local filename = {
        "filename",
        path = 1,
        color = { gui = "bold", bg = terafox.blue.base, fg = terafox.bg2 },
        separator = { left = "", right = "" },
      }

      local filetype = {
        "filetype",
        icon_only = true,
        colored = true,
        color = { gui = "bold", bg = terafox.bg2 },
        separator = { left = "", right = "" },
      }

      local buffer = {
        require("tabline").tabline_buffers,
        color = { gui = "bold" },
        separator = { left = "", right = "" },
      }

      local tabs = {
        require("tabline").tabline_tabs,
        separator = { left = "", right = "" },
      }

      local branch = {
        "branch",
        color = { gui = "bold", bg = terafox.magenta.bright, fg = terafox.bg2 },
        separator = { left = "", right = "" },
      }

      local diff = {
        "diff",
        color = { gui = "bold", bg = terafox.bg2, fg = terafox.bg2 },
        separator = { left = "", right = "" },
      }

      local modes = {
        "mode",
        color = { gui = "bold" },
        separator = { left = "", right = "" },
      }

      local location = {
        "location",
        color = { gui = "bold", bg = terafox.magenta.bright, fg = terafox.bg2 },
        separator = { left = "", right = "" },
      }

      local dia = {
        "diagnostics",
        color = { gui = "bold", bg = terafox.bg2, fg = "#80A7EA" },
        separator = { left = "", right = "" },
      }

      local lsp = {
        function()
          local empty = "..."
          local servers = {}
          local buf_ft = vim.api.nvim_buf_get_option(0, "filetype")
          local clients = vim.lsp.get_active_clients()
          if next(clients) ~= nil then
            for _, client in ipairs(clients) do
              local filetypes = client.config.filetypes
              if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
                table.insert(servers, client.name)
              end
            end
          end
          return "  " .. (#servers > 0 and table.concat(servers, " / ") or empty)
        end,
        separator = { left = "", right = "" },
        color = { gui = "bold", bg = terafox.green.dim, fg = "#0e1c1d" },
      }

      require("lualine").setup({
        options = {
          icons_enabled = true,
          theme = theme,
          component_separators = { left = "", right = "" },
          section_separators = { left = "", right = "" },
          disabled_filetypes = {
            statusline = {},
            winbar = {},
          },
          ignore_focus = {},
          always_divide_middle = true,
          globalstatus = true,
          refresh = {
            statusline = 1000,
            tabline = 1000,
            winbar = 1000,
          },
        },
        sections = {
          lualine_a = {
            modes,
          },
          lualine_b = {
            space,
          },
          lualine_c = {
            branch,
            diff,
            space,
            filename,
            filetype,
          },
          lualine_x = {},
          lualine_y = { location, space },
          lualine_z = {
            dia,
            lsp,
          },
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = { "filename" },
          lualine_x = { "location" },
          lualine_y = {},
          lualine_z = {},
        },
        tabline = {
          lualine_a = {
            buffer,
          },
          lualine_b = {},
          lualine_c = {},
          lualine_x = { tabs },
          lualine_y = {},
          lualine_z = {},
        },
        winbar = {},
        inactive_winbar = {},
        -- extensions = { "neo-tree" },
      })
    end,
  },
  {
    "SmiteshP/nvim-navic",
    enabled = false,
  },
  {
    "goolord/alpha-nvim",
    enabled = false,
  },
  {
    "mini.indentscope",
    opts = {
      symbol = "▏",
      draw = {
        delay = 0,
        animation = function()
          return 5
        end,
      },
      options = { try_as_border = false },
    },
  },
}

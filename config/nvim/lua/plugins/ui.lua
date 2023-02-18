return {
  {
    "rcarriga/nvim-notify",
    enabled = false,
  },
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
      -- cmdline = {
      --   view = "cmdline",
      -- },
      messages = {
        view = "mini",
        view_error = "mini",
        view_warn = "mini",
      },
      presets = {
        bottom_search = true,
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
  { "norcalli/nvim-colorizer.lua", lazy = false },
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    -- @credit https://github.com/Strazil001/Nvim/blob/main/after/plugin/lualine.lua
    opts = function()
      local terafox = require("nightfox.palette").load("terafox")
      local theme = {
        normal = {
          a = { fg = terafox.bg2, bg = terafox.green.dim },
          b = {},
          c = {},
        },
        insert = { a = { fg = terafox.black.dim, bg = terafox.yellow.bright } },
        visual = { a = { fg = terafox.black.dim, bg = "#835d98" } },
        replace = { a = { fg = terafox.black.dim, bg = terafox.orange.bright } },
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
        "buffers",
        buffers_color = {
          active = { gui = "bold", bg = terafox.green.dim, fg = "#e6eaea" },
          inactive = { gui = "bold", bg = terafox.bg3, fg = "#e6eaea" }, -- Color for inactive buffer.
        },
        separator = { left = "", right = "" },
        symbols = {
          modified = " ●", -- Text to show when the buffer is modified
          alternate_file = "# ", -- Text to show to identify the alternate file
          directory = " ", -- Text to show when the buffer is a directory
        },
        filetype_names = {
          ["neo-tree"] = "NeoTree",
          lazy = "Lazy",
          mason = "Mason",
          lspinfo = "LspInfo",
          ["null-ls-info"] = "NullLsInfo",
        },
      }

      local tabs = {
        "tabs",
        tabs_color = {
          active = { gui = "bold", bg = terafox.green.dim, fg = "#e6eaea" },
          inactive = { gui = "bold", bg = terafox.bg3, fg = "#e6eaea" }, -- Color for inactive buffer.
        },
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
        color = { gui = "bold", bg = terafox.cyan.bright, fg = terafox.bg2 },
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

      return {
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
            filename,
            filetype,
            space,
            branch,
            diff,
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
      }
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

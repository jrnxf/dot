return {
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
        },
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
    config = function()
      require("tabline").setup({
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
      })
      vim.cmd([[
        set guioptions-=e " Use showtabline in gui vim
        set sessionoptions+=tabpages,globals " store tabpages and globals in session
      ]])
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "keklleo/tabline.nvim" },
    event = "VeryLazy",

    -- opts = function(_, opts)
    --   opts.sections.lualine_a = {
    --     { "mode", separator = { left = "" },
    --       -- padding = { right = 2 }
    --     }
    --   }
    --   opts.sections.lualine_z = { {

    --     function()
    --       return " " .. os.date("%R")
    --     end,
    --     separator = { right = "" }
    --   }

    --   }
    --   opts.options.section_separators = { left = "", right = "" }
    --   opts.options.component_separators = { left = "", right = "" }
    -- end,

    -- @credit https://github.com/Strazil001/Nvim/blob/main/after/plugin/lualine.lua
    config = function()
      local colors = {
        red = "#cdd6f4",
        grey = "#181825",
        black = "#0e1c1d",
        white = "#313244",
        light_green = "#6c7086",
        orange = "#fab387",
        green = "#a6e3a1",
        blue = "#80A7EA",
      }

      local theme = {
        normal = {
          a = { fg = colors.black, bg = colors.blue },
          b = { fg = colors.blue, bg = colors.white },
          c = { fg = colors.white, bg = colors.black },
          z = { fg = colors.white, bg = colors.black },
        },
        insert = { a = { fg = colors.black, bg = colors.orange } },
        visual = { a = { fg = colors.black, bg = colors.green } },
        replace = { a = { fg = colors.black, bg = colors.green } },
      }
      local function getLspText()
        -- local msg = "No Active LSPs"
        local msg = ""
        local buf_ft = vim.api.nvim_buf_get_option(0, "filetype")
        local clients = vim.lsp.get_active_clients()
        if next(clients) == nil then
          return msg
        end

        for _, client in ipairs(clients) do
          local filetypes = client.config.filetypes
          if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
            msg = msg .. client.name .. ","
          end
        end
        return "  " .. msg
      end

      local terafox = require("nightfox.palette").load("terafox")
      --   bg0 = "#0f1c1e",
      --   bg1 = "#152528",
      --   bg2 = "#1d3337",
      --   bg3 = "#254147",
      --   bg4 = "#2d4f56",
      --   black = {
      --     base = "#2f3239",
      --     bright = "#4e5157",
      --     dim = "#282a30",
      --     light = false,
      --     <metatable> = <1>{
      --       __call = <function 1>,
      --       __index = <table 1>,
      --       harsh = <function 2>,
      --       new = <function 3>,
      --       subtle = <function 4>
      --     }
      --   },
      --   blue = {
      --     base = "#5a93aa",
      --     bright = "#73a3b7",
      --     dim = "#4d7d90",
      --     light = false,
      --     <metatable> = <table 1>
      --   },
      --   comment = "#6d7f8b",
      --   cyan = {
      --     base = "#a1cdd8",
      --     bright = "#afd4de",
      --     dim = "#89aeb8",
      --     light = false,
      --     <metatable> = <table 1>
      --   },
      --   fg0 = "#eaeeee",
      --   fg1 = "#e6eaea",
      --   fg2 = "#cbd9d8",
      --   fg3 = "#587b7b",
      --   generate_spec = <function 5>,
      --   green = {
      --     base = "#7aa4a1",
      --     bright = "#8eb2af",
      --     dim = "#688b89",
      --     light = false,
      --     <metatable> = <table 1>
      --   },
      --   magenta = {
      --     base = "#ad5c7c",
      --     bright = "#b97490",
      --     dim = "#934e69",
      --     light = false,
      --     <metatable> = <table 1>
      --   },
      --   meta = {
      --     light = false,
      --     name = "terafox"
      --   },
      --   orange = {
      --     base = "#ff8349",
      --     bright = "#ff9664",
      --     dim = "#d96f3e",
      --     light = false,
      --     <metatable> = <table 1>
      --   },
      --   pink = {
      --     base = "#cb7985",
      --     bright = "#d38d97",
      --     dim = "#ad6771",
      --     light = false,
      --     <metatable> = <table 1>
      --   },
      --   red = {
      --     base = "#e85c51",
      --     bright = "#eb746b",
      --     dim = "#c54e45",
      --     light = false,
      --     <metatable> = <table 1>
      --   },
      --   sel0 = "#293e40",
      --   sel1 = "#425e5e",
      --   white = {
      --     base = "#ebebeb",
      --     bright = "#eeeeee",
      --     dim = "#c8c8c8",
      --     light = false,
      --     <metatable> = <table 1>
      --   },
      --   yellow = {
      --     base = "#fda47f",
      --     bright = "#fdb292",
      --     dim = "#d78b6c",
      --     light = false,
      --     <metatable> = <table 1>
      --   }
      -- }
      local vim_icons = {
        function()
          return " "
        end,
        separator = { left = "", right = "" },
        color = { bg = "#313244", fg = "#80A7EA" },
      }

      local space = {
        function()
          return " "
        end,
        color = { bg = colors.black, fg = "#80A7EA" },
      }

      local filename = {
        "filename",
        color = { bg = terafox.blue.base, fg = "#242735" },
        separator = { left = "", right = "" },
      }

      local filetype = {
        "filetype",
        icon_only = true,
        colored = true,
        color = { bg = "#313244" },
        separator = { left = "", right = "" },
      }

      local filetype_tab = {
        "filetype",
        icon_only = true,
        colored = true,
        color = { bg = "#313244" },
      }

      local buffer = {
        require("tabline").tabline_buffers,
        separator = { left = "", right = "" },
      }

      local tabs = {
        require("tabline").tabline_tabs,
        separator = { left = "", right = "" },
      }

      local fileformat = {
        "fileformat",
        color = { bg = terafox.blue.bright, fg = "#313244" },
        separator = { left = "", right = "" },
      }

      local encoding = {
        "encoding",
        color = { bg = "#313244", fg = "#80A7EA" },
        separator = { left = "", right = "" },
      }

      local branch = {
        "branch",
        color = { bg = terafox.green.bright, fg = "#313244" },
        separator = { left = "", right = "" },
      }

      local diff = {
        "diff",
        color = { bg = "#313244", fg = "#313244" },
        separator = { left = "", right = "" },
      }

      local modes = {
        "mode",
        fmt = function(str)
          return str:sub(1, 1)
        end,
        color = { bg = "#fab387		", fg = "#0e1c1d" },
        separator = { left = "", right = "" },
      }

      local dia = {
        "diagnostics",
        color = { bg = "#313244", fg = "#80A7EA" },
        separator = { left = "", right = "" },
      }

      local lsp = {
        function()
          return getLspText()
        end,
        separator = { left = "", right = "" },
        color = { bg = terafox.magenta.bright, fg = "#0e1c1d" },
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
            --{ 'mode', fmt = function(str) return str:gsub(str, "  ") end },
            modes,
            --{ 'mode', fmt = function(str) return str:sub(1, 1) end },
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
          lualine_x = {
            space,
          },
          lualine_y = {
            encoding,
            fileformat,
            space,
          },
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
          lualine_x = {},
          lualine_y = {},
          lualine_z = {
            tabs,
          },
        },
        winbar = {},
        inactive_winbar = {},
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

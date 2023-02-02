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
  { "norcalli/nvim-colorizer.lua" },
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",


    opts = function(_, opts)
      opts.sections.lualine_a = {
        { "mode", separator = { left = "" },
          -- padding = { right = 2 }
        }
      }
      opts.sections.lualine_z = { {

        function()
          return " " .. os.date("%R")
        end,
        separator = { right = "" }
      }

      }
      opts.options.section_separators = { left = "", right = "" }
      opts.options.component_separators = { left = "", right = "" }
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

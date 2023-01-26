return {
  {
    "folke/tokyonight.nvim",
    opts = { style = "night" },
  },
  {
    "EdenEast/nightfox.nvim",
    lazy = false,
    config = function()
      local terafox = require("nightfox.palette").load("terafox")

      local colors = {
        added_line = "#0e3929",
        added_text = "#19674a",
        deleted_line = "#2d1c1c",
        deleted_text = "#4e3131",
        off_white_text = "#cccccc",
      }
      local groups = {
        -- general
        -- Search = { fg = 'white', bg = terafox.magenta.dim },
        -- IncSearch = { fg = 'white', bg = terafox.yellow.dim },
        CmpPmenuBorder = { link = "NormalFloatBorder" },
        CursorLine = { bg = terafox.bg1 },
        DiagnosticSignInfo = { link = "FloatBorder" }, -- used heavily by noice
        DiffAdd = { bg = colors.added_line }, -- show added lines
        DiffAddAsDelete = { bg = colors.deleted_line }, -- used in diffview (left panel) highlight line that changed
        DiffAddText = { bg = colors.added_text, fg = colors.off_white_text }, -- show added characters within added lines
        DiffChange = { bg = colors.deleted_line }, -- fugitive (left side) to show what LINE text was changed on
        DiffDelete = { bg = colors.deleted_line, fg = colors.deleted_text }, -- shows fully deleted blocks of code
        DiffDeleteText = { bg = colors.deleted_text, fg = colors.off_white_text }, -- diffview (left panel) highlight word that changed
        DiffText = { bg = colors.deleted_text, fg = colors.off_white_text }, -- fugitive (left side) to show exact characters that deleted
        FloatBorder = { fg = terafox.bg3 },
        LspInfoBorder = { link = "FloatBorder" },
        MasonHeader = { bg = terafox.green.dim },
        MasonHeaderSecondary = { bg = terafox.green.dim },
        MasonHighlightBlock = { bg = terafox.green.dim },
        MasonHighlightBlockBold = { bg = terafox.green.dim },
        Normal = { bg = terafox.bg0 },
        NormalFloat = { bg = terafox.bg0 },
        NormalFloatBorder = { link = "FloatBorder" },
        NormalNC = { bg = terafox.bg0 },
        NullLsInfoBorder = { link = "FloatBorder" }, -- TODO pr this - it's weird that they used NormalFloat here and not NormalFloatBorder
        NullLsInfoTitle = { link = "Title" },
        Pmenu = { bg = terafox.bg1 },
        PmenuBorder = { link = "FloatBorder" },
        StatusLine = { bg = "#152528" }, -- this must be style different that NC otherwise vim will use ^^^^^^ to differentiate
        StatusLineNC = { bg = "#152528", fg = "#7aa4a1" }, -- status line none current
        Substitute = { bg = terafox.magenta.dim, fg = "white" },
        TelescopeBorder = { link = "FloatBorder" },
        VertSplit = { fg = terafox.bg2 },
      }
      require("nightfox").setup({
        options = {
          styles = {
            comments = "italic",
            keywords = "bold",
            types = "italic,bold",
          },
        },
        groups = {
          terafox = groups,
        },
      })

      vim.cmd("colorscheme terafox")
    end,
  },
  -- {
  --   "rmehri01/onenord.nvim",
  --   -- config = function()
  --   --   local colors = {
  --   --     -- primary = "#151a23",
  --   --     primary = "#191f29",
  --   --     secondary = "#191f29",
  --   --     tertiary = "#1d242f",
  --   --   }
  --   --
  --   --   -- paste in command mode to see available colors
  --   --   -- lua print(vim.inspect(require("onenord.colors").load()))
  --   --
  --   --   -- require("onenord").setup({
  --   --   --   custom_highlights = {
  --   --   --     CursorLine = { -- this is really tough to see
  --   --   --       bg = colors.tertiary,
  --   --   --     },
  --   --   --   },
  --   --   --   custom_colors = {
  --   --   --     bg = colors.secondary,
  --   --   --     active = colors.secondary,
  --   --   --   },
  --   --   -- })
  --   -- end,
  -- },
}

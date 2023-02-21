return {
  {
    "folke/tokyonight.nvim",
    opts = { style = "night" },
  },
  {
    "EdenEast/nightfox.nvim",
    lazy = false,
    priority = 1000,
    opts = function()
      local terafox = require("nightfox.palette").load("terafox")

      -- {
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
        LeapBackdrop = { link = "Comment" },
        LeapMatch = { bg = terafox.magenta.dim, fg = colors.off_white_text },
        LeapLabelPrimary = { bg = terafox.sel0, fg = colors.off_white_text },
        LeapLabelSecondary = { bg = terafox.sel1, fg = colors.off_white_text },
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
        -- FzfLuaBorder = { link = "FloatBorder" },
        PmenuBorder = { link = "FloatBorder" },
        StatusLine = { bg = "#152528" }, -- this must be style different that NC otherwise vim will use ^^^^^^ to differentiate
        StatusLineNC = { bg = "#152528", fg = "#7aa4a1" }, -- status line none current
        Substitute = { bg = terafox.magenta.dim, fg = "white" },
        TelescopeBorder = { link = "FloatBorder" },
        TelescopeResultsNormal = { link = "Comment" },
        VertSplit = { fg = terafox.bg2 },
      }

      return {
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
      }
    end,
  },
}

local Util = require("lazyvim.util")

return {
  {
    "ggandor/leap.nvim",
    opts = function()
      require("leap").opts.safe_labels = {}
    end,
  },
  {
    "lewis6991/gitsigns.nvim",
    event = "BufReadPre",
    opts = {
      current_line_blame = true,
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
        delay = 0,
        ignore_whitespace = false,
      },
      signs = {
        add = { text = "│" },
        change = { text = "│" },
        delete = { text = "│" },
        topdelete = { text = "│" },
        changedelete = { text = "│" },
        untracked = { text = "│" },
      },
    },
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    keys = {
      { "<leader>E", "<leader>fe", desc = "Explorer NeoTree (root dir)", remap = true },
      { "<leader>e", "<leader>fE", desc = "Explorer NeoTree (cwd)", remap = true },
    },
    opts = {
      close_if_last_window = true, -- Close Neo-tree if it is the last window left in the tab
      filesystem = {
        follow_current_file = true, -- This will find and focus the file in the active buffer every
        -- time the current file is changed while the tree is open.
        group_empty_dirs = true, -- when true, empty folders will be grouped together
      },
    },
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      window = {
        border = "rounded",
      },
    },
  },
  {
    "simrat39/symbols-outline.nvim",
    lazy = false,
    opts = {
      highlight_hovered_item = true,
      show_guides = true,
      auto_preview = false,
      position = "right",
      relative_width = true,
      width = 25,
      auto_close = false,
      show_numbers = false,
      show_relative_numbers = false,
      show_symbol_details = true,
      preview_bg_highlight = "Pmenu",
      autofold_depth = nil,
      auto_unfold_hover = true,
      fold_markers = { "", "" },
      wrap = false,
      keymaps = { -- These keymaps can be a string or a table for multiple keys
        close = { "<Esc>", "q" },
        goto_location = "<Cr>",
        focus_location = "o",
        hover_symbol = "<C-space>",
        toggle_preview = "K",
        rename_symbol = "r",
        code_actions = "a",
        fold = "h",
        unfold = "l",
        fold_all = "W",
        unfold_all = "E",
        fold_reset = "R",
      },
      lsp_blacklist = {},
      symbol_blacklist = {},
      symbols = {
        File = { icon = "", hl = "@text.uri" },
        Module = { icon = "", hl = "@namespace" },
        Namespace = { icon = "", hl = "@namespace" },
        Package = { icon = "", hl = "@namespace" },
        Class = { icon = "𝓒", hl = "@type" },
        Method = { icon = "ƒ", hl = "@method" },
        Property = { icon = "", hl = "@method" },
        Field = { icon = "", hl = "@field" },
        Constructor = { icon = "", hl = "@constructor" },
        Enum = { icon = "ℰ", hl = "@type" },
        Interface = { icon = "ﰮ", hl = "@type" },
        Function = { icon = "", hl = "@function" },
        Variable = { icon = "", hl = "@constant" },
        Constant = { icon = "", hl = "@constant" },
        String = { icon = "𝓐", hl = "@string" },
        Number = { icon = "#", hl = "@number" },
        Boolean = { icon = "⊨", hl = "@boolean" },
        Array = { icon = "", hl = "@constant" },
        Object = { icon = "⦿", hl = "@type" },
        Key = { icon = "🔐", hl = "@type" },
        Null = { icon = "NULL", hl = "@type" },
        EnumMember = { icon = "", hl = "@field" },
        Struct = { icon = "𝓢", hl = "@type" },
        Event = { icon = "🗲", hl = "@type" },
        Operator = { icon = "+", hl = "@operator" },
        TypeParameter = { icon = "𝙏", hl = "@parameter" },
        Component = { icon = "", hl = "@function" },
        Fragment = { icon = "", hl = "@constant" },
      },
    },
  },
  {
    "stevearc/aerial.nvim",
    enabled = false,
    lazy = false,
    opts = function()
      return {

        backends = { "lsp", "treesitter", "markdown", "man" },
        filter_kind = false,
        -- -- Use symbol tree for folding. Set to true or false to enable/disable
        -- -- Set to "auto" to manage folds if your previous foldmethod was 'manual'
        -- -- This can be a filetype map (see :help aerial-filetype-map)
        -- manage_folds = true,

        -- -- When you fold code with za, zo, or zc, update the aerial tree as well.
        -- -- Only works when manage_folds = true
        -- link_folds_to_tree = false,
        --
        -- -- Fold code when you open/collapse symbols in the tree.
        -- -- Only works when manage_folds = true
        -- link_tree_to_folds = true,
        -- optionally use on_attach to set keymaps when aerial has attached to a buffer
        show_guides = true,
        on_attach = function(bufnr)
          -- Jump forwards/backwards with '{' and '}'
          vim.keymap.set("n", "{", "<cmd>AerialPrev<CR>", { buffer = bufnr })
          vim.keymap.set("n", "}", "<cmd>AerialNext<CR>", { buffer = bufnr })
        end,
        layout = {
          -- These control the width of the aerial window.
          -- They can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
          -- min_width and max_width can be a list of mixed types.
          -- max_width = {40, 0.2} means "the lesser of 40 columns or 20% of total"
          max_width = { 50, 0.3 },
          min_width = 40,
          placement = "edge",
        },

        post_jump_cmd = "normal! zz",

        attach_mod = "global",
        update_events = "TextChanged,InsertLeave",
        -- Options for opening aerial in a floating win

        highlight_on_hover = true,
      }
    end,
  },
  {
    "liangxianzhe/nap.nvim",
    dependencies = { "stevearc/aerial.nvim", "lewis6991/gitsigns.nvim" },
    lazy = false,
    opts = {
      next_prefix = "<c-n>",
      prev_prefix = "<c-p>",
      next_repeat = "<cr>",
      prev_repeat = "<tab>",
    },
    config = function(_, opts)
      local nap = require("nap")
      nap.setup(opts)
      nap.nap("h", "Gitsigns next_hunk", "Gitsigns prev_hunk", "Next diff", "Previous diff")
      nap.nap("o", "AerialNext", "AerialPrev", "Next outline symbol", "Previous outline symbol")
      nap.nap("x", "TroubleNext", "TroublePrevious", "Next Trouble Item", "Previous Trouble Item")
      nap.nap("t", "tabnext", "tabprevious", "Next Tab", "Previous Tab")
      nap.nap("b", "bnext", "bprevious", "Next Buffer", "Previous Buffer")
    end,
  },
  {
    "folke/trouble.nvim",
    opts = {
      -- auto_open = true, -- this is nice sometimes
      auto_close = true,
      auto_jump = { "lsp_definitions", "lsp_type_definitions", "lsp_references", "lsp_implementations" }, -- for the given modes, automatically jump if there is only a single result
      sort_keys = {
        -- 'severity', -- I prefer to have my errors displayed top to bottom in the file vs by severity
        "filename",
        "lnum",
        "col",
      },
    },
    config = function(_, opts)
      local trouble = require("trouble")
      trouble.setup(opts)

      vim.api.nvim_create_user_command("TroubleNext", function()
        -- jump to the next item, skipping the groups
        trouble.next({ skip_groups = true, jump = true })
      end, {})
      vim.api.nvim_create_user_command("TroublePrevious", function()
        -- jump to the next item, skipping the groups
        trouble.previous({ skip_groups = true, jump = true })
      end, {})
    end,
  },
  -- {
  --   "ibhagwan/fzf-lua",
  --   cmd = {
  --     "FzfLua",
  --   },
  --   keys = {
  --     { "<leader>,", "<cmd>lua require'fzf-lua'.buffers()<cr>", desc = "Switch Buffer" },
  --     { "<leader>:", "<cmd>lua require'fzf-lua'.command_history()<cr>", desc = "Command History" },
  --     { "<c-space><c-space>", "<cmd>lua require'fzf-lua'.live_grep_glob()<cr>", desc = "Find in Files (Grep)" },
  --     { "<a-space><a-space>", "<cmd>lua require'fzf-lua'.builtin()<cr>", desc = "Fzf Builtins" },
  --     { "<leader><leader>", "<cmd>lua require'fzf-lua'.files()<cr>", desc = "Find Files" },
  --     { "<leader>r", "<cmd>lua require'fzf-lua'.oldfiles()<cr>", desc = "Recent Files" },
  --     { "<leader>gc", "<cmd>lua require'fzf-lua'.git_commits()<cr>", desc = "commits" },
  --     { "<leader>gs", "<cmd>lua require'fzf-lua'.git_status()<cr>", desc = "status" },
  --     { "<leader>sb", "<cmd>lua require'fzf-lua'.grep_curbuf()<cr>", desc = "Buffer" },
  --     { "<leader>sC", "<cmd>lua require'fzf-lua'.commands()<cr>", desc = "Commands" },
  --     { "<leader>sd", "<cmd>lua require'fzf-lua'.diagnostics_document()<cr>", desc = "Diagnostics (Document)" },
  --     { "<leader>sD", "<cmd>lua require'fzf-lua'.diagnostics_workspace()<cr>", desc = "Diagnostics (Workspace)" },
  --     { "<leader>sh", "<cmd>lua require'fzf-lua'.help_tags()<cr>", desc = "Help Tags" },
  --     { "<leader>sH", "<cmd>lua require'fzf-lua'.highlights()<cr>", desc = "Search Highlight Groups" },
  --     { "<leader>sk", "<cmd>lua require'fzf-lua'.keymaps()<cr>", desc = "Key Maps" },
  --     { "<leader>sw", "<cmd>lua require'fzf-lua'.grep_cword()<cr>", desc = "Word" },
  --     { "<leader>uC", "<cmd>lua require'fzf-lua'.colorschemes()<cr>", desc = "Colorscheme with preview" },
  --     { "<leader>xx", "<cmd>lua require'fzf-lua'.diagnostics_document()<cr>", desc = "Document Diagnostics" },
  --     { "<leader>xX", "<cmd>lua require'fzf-lua'.diagnostics_workspace()<cr>", desc = "Workspace Diagnostics" },
  --   },
  --   opts = {
  --     winopts = {
  --       hl = { border = "FloatBorder" },
  --       preview = {
  --         vertical = "up:60%", -- up|down:size
  --         horizontal = "right:60%", -- right|left:size
  --         layout = "flex", -- horizontal|vertical|flex
  --         delay = 0, -- delay(ms) displaying the preview, prevents lag on fast scrolling
  --       },
  --     },
  --     fzf_colors = {
  --       ["gutter"] = { "bg", "Normal" },
  --     },
  --
  --     keymap = {
  --       builtin = {
  --         ["<C-f>"] = "preview-page-down", -- Add this lines
  --         ["<C-b>"] = "preview-page-up", -- Add this line
  --       },
  --     },
  --
  --     previewers = {
  --       bat = {
  --         cmd = "bat",
  --         args = "--style=numbers,changes --color always --line-range :500",
  --         theme = "ansi",
  --       },
  --     },
  --
  --     helptags = {
  --       prompt = "",
  --       winopts = {
  --         preview = {
  --           layout = "vertical",
  --         },
  --       },
  --     },
  --
  --     manpages = {
  --       prompt = "",
  --       winopts = {
  --         preview = {
  --           layout = "vertical",
  --         },
  --       },
  --     },
  --
  --     grep = {
  --       prompt = "Rg❯ ",
  --       input_prompt = "Grep For❯ ",
  --       -- prompt = "",
  --       -- prompt = "",
  --       winopts = {
  --         preview = {
  --           layout = "vertical",
  --           width = 0.60,
  --           height = 0.4,
  --         },
  --       },
  --
  --       git_icons = false, -- show git icons?
  --       file_icons = false, -- show file icons?
  --       color_icons = false, -- colorize file|git icons
  --       keymap = {
  --         fzf = {
  --           ["ctrl-h"] = "transform-query(echo '{q} -- ')",
  --         },
  --       },
  --       actions = {
  --         ["ctrl-g"] = false,
  --       },
  --       no_header = true, -- hide grep|cwd header?
  --       no_header_i = true, -- hide interactive header?
  --     },
  --
  --     builtin = {
  --       previewer = false,
  --       prompt = "",
  --       winopts = {
  --         width = 0.60,
  --         height = 0.4,
  --       },
  --     },
  --     oldfiles = {
  --       cwd_only = true,
  --       previewer = false,
  --       prompt = "",
  --       winopts = {
  --         width = 0.60,
  --         height = 0.4,
  --       },
  --
  --       git_icons = false, -- show git icons?
  --       file_icons = false, -- show file icons?
  --       color_icons = false, -- colorize file|git icons
  --     },
  --     files = {
  --       previewer = false,
  --       winopts = {
  --         width = 0.60,
  --         height = 0.4,
  --       },
  --       git_icons = false, -- show git icons?
  --       file_icons = false, -- show file icons?
  --       color_icons = false, -- colorize file|git icons
  --     },
  --   },
  --   -- optional for icon support
  --   dependencies = { "nvim-tree/nvim-web-devicons" },
  -- },

  -- {
  --   "nvim-telescope/telescope.nvim",
  --   enabled = false,
  -- },
  -- {
  --   "princejoogie/dir-telescope.nvim",
  --   -- telescope.nvim is a required dependency
  --   requires = { "telescope" },
  --   lazy = false,
  --   opts = {
  --     hidden = true,
  --     respect_gitignore = true,
  --   },
  -- },

  { "molecule-man/telescope-menufacture", lazy = false },
  {

    "nvim-telescope/telescope.nvim",
    -- dir = "~/Dev/telescope.nvimmm",
    cmd = "Telescope",
    version = false, -- telescope did only one release, so use HEAD for now
    keys = {
      { "<leader>,", "<cmd>Telescope buffers show_all_buffers=true<cr>", desc = "Switch Buffer" },
      {
        "<c-space><c-space>",
        function()
          require("telescope").extensions.menufacture.live_grep()
        end,
        desc = "Find in Files (Grep)",
      },
      {
        "<leader><leader>",
        function()
          require("telescope").extensions.menufacture.find_files()
        end,
        desc = "Find Files (root dir)",
      },
      { "<leader>:", "<cmd>Telescope command_history<cr>", desc = "Command History" },
      { "<a-space><a-space>", "<cmd>Telescope builtin<cr>", desc = "Telescope Builtins" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
      { "<leader>ff", Util.telescope("files"), desc = "Find Files (root dir)" },
      { "<leader>fF", Util.telescope("files", { cwd = false }), desc = "Find Files (cwd)" },
      { "<leader>r", "<cmd>Telescope oldfiles<cr>", desc = "Recent" },
      { "<leader>gc", "<cmd>Telescope git_commits<CR>", desc = "commits" },
      { "<leader>gs", "<cmd>Telescope git_status<CR>", desc = "status" },
      { "<leader>sa", "<cmd>Telescope autocommands<cr>", desc = "Auto Commands" },
      { "<leader>sb", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Buffer" },
      { "<leader>sc", "<cmd>Telescope command_history<cr>", desc = "Command History" },
      { "<leader>sC", "<cmd>Telescope commands<cr>", desc = "Commands" },
      { "<leader>sd", "<cmd>Telescope diagnostics<cr>", desc = "Diagnostics" },
      { "<leader>sg", Util.telescope("live_grep"), desc = "Grep (root dir)" },
      { "<leader>sG", Util.telescope("live_grep", { cwd = false }), desc = "Grep (cwd)" },
      { "<leader>sh", "<cmd>Telescope help_tags<cr>", desc = "Help Pages" },
      { "<leader>sH", "<cmd>Telescope highlights<cr>", desc = "Search Highlight Groups" },
      { "<leader>sk", "<cmd>Telescope keymaps<cr>", desc = "Key Maps" },
      { "<leader>sM", "<cmd>Telescope man_pages<cr>", desc = "Man Pages" },
      { "<leader>sm", "<cmd>Telescope marks<cr>", desc = "Jump to Mark" },
      { "<leader>so", "<cmd>Telescope vim_options<cr>", desc = "Options" },
      { "<leader>sw", Util.telescope("grep_string"), desc = "Word (root dir)" },
      { "<leader>sW", Util.telescope("grep_string", { cwd = false }), desc = "Word (cwd)" },
      { "<leader>uC", Util.telescope("colorscheme", { enable_preview = true }), desc = "Colorscheme with preview" },
      {
        "<leader>ss",
        Util.telescope("lsp_document_symbols", {
          symbols = {
            "Class",
            "Function",
            "Method",
            "Constructor",
            "Interface",
            "Module",
            "Struct",
            "Trait",
            "Field",
            "Property",
          },
        }),
        desc = "Goto Symbol",
      },
    },
    opts = {
      defaults = {
        path_display = { "smart" },
        prompt_prefix = " ",
        selection_caret = " ",
        mappings = {
          i = {
            ["<c-t>"] = function(...)
              return require("trouble.providers.telescope").open_with_trouble(...)
            end,
            ["<a-i>"] = function()
              Util.telescope("find_files", { no_ignore = true })()
            end,
            ["<a-h>"] = function()
              Util.telescope("find_files", { hidden = true })()
            end,
            ["<C-Down>"] = function(...)
              return require("telescope.actions").cycle_history_next(...)
            end,
            ["<C-Up>"] = function(...)
              return require("telescope.actions").cycle_history_prev(...)
            end,
            ["<C-f>"] = function(...)
              return require("telescope.actions").preview_scrolling_down(...)
            end,
            ["<C-b>"] = function(...)
              return require("telescope.actions").preview_scrolling_up(...)
            end,
          },
          n = {
            ["q"] = function(...)
              return require("telescope.actions").close(...)
            end,
          },
        },
      },
    },
    -- keys = {
    --     { "<leader>bl", "<cmd>Telescope buffers<cr>", desc = "List Buffers" },
    -- },
    dependencies = { { "nvim-telescope/telescope-fzf-native.nvim", build = "make" }, "folke/trouble.nvim", "nvim-telescope/telescope-live-grep-args.nvim", "molecule-man/telescope-menufacture" },
    -- apply the config and additionally load fzf-native
    config = function()
      local telescope = require("telescope")
      -- local builtin = require("telescope.builtin")
      local actions = require("telescope.actions")
      local trouble = require("trouble.providers.telescope")
      local lga_actions = require("telescope-live-grep-args.actions")

      local dropdown_opts = {
        theme = "dropdown",
        previewer = false,
      }

      -- local minimal = {
      --   theme = "minimal",
      --   layout_strategy = "horizontal",
      --   layout_config = {
      --     -- prompt_position = "bottom",
      --     width = 200,
      --     height = 35,
      --     -- preview_height = 25,
      --   },

      --   disable_devicons = true,
      --   prompt_title = "",
      --   results_title = "",
      --   preview_title = "",
      -- }

      telescope.setup({
        defaults = {
          vimgrep_arguments = {
            "rg",
            -- telescope defaults
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            -- '--smart-case', -- i prefer ignore case
            -- custom
            "--ignore-case",
            "--fixed-strings",
            "--sort=path",
          },
          -- theme = minimal,
          --
          path_display = function(_, path)
            local tail = require("telescope.utils").path_tail(path)
            path = path:sub(1, (#tail + 1) * -1)

            if path:sub(-1) == "/" then
              path = path:sub(1, -2)
            end

            if #path > 0 then
              path = string.format(" (%s)", path)
            end

            return string.format("%s%s", tail, path)
          end,
          results_title = false,
          -- layout_strategy = "vertical",
          layout_strategy = "horizontal",
          layout_config = {
            vertical = { width = 0.9, height = 0.9, preview_height = 0.6, prompt_position = "top", preview_position = "bottom", mirror = true },
            horizontal = { width = 0.9, height = 0.9, preview_width = 0.6, prompt_position = "top" },
          },
          -- layout_config = { prompt_position = "top" },
          sorting_strategy = "ascending",
          winblend = 5,
          -- prompt_position = "top",
          file_ignore_patterns = { "node_modules/.*" },
          mappings = {
            i = {
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
              ["<C-d>"] = actions.delete_buffer,
              ["<C-t>"] = trouble.open_with_trouble,
            },
            n = {
              ["<C-c>"] = actions.close,
              ["<C-d>"] = actions.delete_buffer,
              ["<C-t>"] = trouble.open_with_trouble,
            },
          },
        },
        pickers = {
          -- git_files = minimal,
          -- find_files = minimal,
          -- live_grep = minimal,
          help_tags = dropdown_opts,
          oldfiles = dropdown_opts,
        },
        extensions = {
          menufacture = {
            mappings = {
              main_menu = { [{ "i", "n" }] = "<C-h>" },
            },
          },
          live_grep_args = {
            auto_quoting = true, -- enable/disable auto-quoting
            -- define mappings, e.g.
            mappings = { -- extend mappings
              i = {
                ["<C-k>"] = lga_actions.quote_prompt(),
                ["<C-i>"] = lga_actions.quote_prompt({ postfix = " --iglob " }),
              },
            },
            -- ... also accepts theme settings, for example:
            -- theme = "dropdown", -- use dropdown theme
            -- theme = { }, -- use own theme spec
            -- layout_config = { mirror=true }, -- mirror preview pane
          },
          {},
        },
      })
      telescope.load_extension("fzf")
      telescope.load_extension("live_grep_args")
      telescope.load_extension("menufacture")
      -- telescope.load_extension("dir")
    end,
  },
  {
    "sindrets/diffview.nvim",
    dependencies = "nvim-lua/plenary.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory" },
    keys = {
      { "<leader>gdp", "<cmd>DiffviewOpen<cr>", desc = "Diff Project" },
      { "<leader>gdf", "<cmd>DiffviewFileHistory<cr>", desc = "Diff File" },
      { "<leader>gdF", "<cmd>DiffviewFileHistory %<cr>", desc = "Diff File %" },
    },
    opts = function()
      return {
        {
          enhanced_diff_hl = true,
          -- hooks = {
          --   ---@param view StandardView
          --   view_opened = function(view)
          --     local function post_layout()
          --       -- M.tbl_ensure(view, 'winopts.diff2.a')
          --       -- M.tbl_ensure(view, 'winopts.diff2.b')
          --       view.winopts.diff2.a = utils.tbl_union_extend_or_overwrite(view.winopts.diff2.a, {
          --         winhl = {
          --           'DiffChange:DiffAddAsDelete',
          --           'DiffText:DiffDeleteText',
          --         },
          --       })
          --       view.winopts.diff2.b = utils.tbl_union_extend_or_overwrite(view.winopts.diff2.b, {
          --         winhl = {
          --           'DiffChange:DiffAdd',
          --           'DiffText:DiffAddText',
          --         },
          --       })
          --     end

          --     view.emitter:on('post_layout', post_layout)
          --     post_layout()
          --   end,
          -- },
          keymaps = {
            view = {
              ["gf"] = require("diffview.actions").goto_file_edit,
              ["-"] = require("diffview.actions").toggle_stage_entry,
            },
            file_panel = {
              ["<cr>"] = require("diffview.actions").focus_entry,
              ["s"] = require("diffview.actions").toggle_stage_entry,
              ["gf"] = require("diffview.actions").goto_file_edit,
            },
            file_history_panel = {
              ["<cr>"] = require("diffview.actions").focus_entry,
              ["gf"] = require("diffview.actions").goto_file_edit,
            },
          },
        },
      }
    end,
  },
}

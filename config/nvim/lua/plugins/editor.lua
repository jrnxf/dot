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
    "nvim-tree/nvim-tree.lua",
    keys = {
      { "<leader>e", "<cmd>NvimTreeToggle<cr>", desc = "Explorer NeoTree (cwd)", remap = true },
    },
    opts = {
      hijack_directories = {
        enable = false, -- don't auto open nvim_tree on directories
      },
      update_focused_file = {
        enable = true,
      },
      diagnostics = {
        enable = true,
      },
      actions = {
        open_file = {
          quit_on_open = true,
          resize_window = true,
        },
      },
      renderer = {
        group_empty = true,
      },
      view = {
        -- hide_root_folder = true,
        adaptive_size = true,
        -- NOTE:
        -- @ref https://github.com/nvim-tree/nvim-tree.lua/pull/1538#issuecomment-1223314278
        -- logic to calculate dynanic, centered tree positioning
        -- float = {
        --   enable = true,
        --   -- NOTE: this makes it so that the vim input/select (via dressing) that steals focus doesn't close nvim-tree
        --   -- I can still <C-w> away from the float and have it not close, which is unfortunate, but I don't mentally
        --   -- think to even try that when in float mode
        --   quit_on_focus_loss = false,
        --   -- end NOTE
        --   open_win_config = function()
        --     local screen_w = vim.opt.columns:get()
        --     local screen_h = vim.opt.lines:get() - vim.opt.cmdheight:get()
        --     local _width = screen_w * 0.3
        --     local _height = screen_h * 0.8
        --     local width = math.floor(_width)
        --     local height = math.floor(_height)
        --     local center_y = ((vim.opt.lines:get() - _height) / 2) - vim.opt.cmdheight:get()
        --     local center_x = (screen_w - _width) / 2
        --     local layouts = {
        --       center = {
        --         anchor = 'NW',
        --         relative = 'editor',
        --         border = 'rounded',
        --         row = center_y,
        --         col = center_x,
        --         width = width,
        --         height = height,
        --       },
        --     }
        --     return layouts.center
        --   end,
        -- },
        -- width = function()
        --   return math.floor(vim.opt.columns:get() * 0.3)
        -- end,
        -- end NOTE
        mappings = {
          custom_only = false, -- false means the list above will merge with defaults
          list = {
            { key = "<C-c>", action = "close" },
            -- { key = '<C-w>', action = 'close' },
            { key = "<C-r>", action = "refresh" },
            -- {
            --   key = "<CR>",
            --   action = "cd_or_open", -- name not relevant, made up by me
            --   action_cb = function(node)
            --     -- if the node is the parent node (name == "..") or a directory
            --     if node.name == ".." or node.fs_stat.type == "directory" then
            --       api.tree.change_root_to_node()
            --     elseif node.fs_stat.type == "file" then
            --       api.node.open.edit()
            --     end
            --   end,
            -- },
            { key = "d",     action = "remove" },
            { key = "h",     action = "close_node" },
            { key = "I",     action = "toggle_ignored" },
            { key = "l",     action = "edit" },
            { key = "r",     action = "rename" },
            { key = "s",     action = "split" },
            { key = "v",     action = "vsplit" },
            { key = "Y",     action = "copy_path" },
            { key = "y",     action = "copy_name" },
          },
        },
      },
    },
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    enabled = false,
    keys = {
      { "<leader>E", "<leader>fe", desc = "Explorer NeoTree (root dir)", remap = true },
      { "<leader>e", "<leader>fE", desc = "Explorer NeoTree (cwd)",      remap = true },
    },
    opts = {
      padding = { right = 50 },
      window = {
        auto_expand_width = true,   -- default: false
      },
      close_if_last_window = true,  -- Close Neo-tree if it is the last window left in the tab
      filesystem = {
        follow_current_file = true, -- This will find and focus the file in the active buffer every
        -- time the current file is changed while the tree is open.
        group_empty_dirs = true,    -- when true, empty folders will be grouped together
      },
    },
  },
  {
    "declancm/cinnamon.nvim",
    opts = {
      hide_cursor = true,
      centered = true,   -- keep lines centered
      default_delay = 2, -- 4ms between each line (a bit faster than default of 7)
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
      keymaps = {
        -- These keymaps can be a string or a table for multiple keys
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

  {
    "nvim-telescope/telescope.nvim",
    enabled = false,
  },
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
  {
    -- "nvim-telescope/telescope.nvim",
    dir = "~/Dev/telescope.nvimmm",
    cmd = "Telescope",
    version = false, -- telescope did only one release, so use HEAD for now
    keys = {
      { "<leader>,",          "<cmd>Telescope buffers show_all_buffers=true<cr>",       desc = "Switch Buffer" },
      { "<c-space><c-space>", "<cmd>Telescope live_grep<cr>",                           desc = "Find in Files (Grep)", },
      { "<leader><leader>",   "<cmd>Telescope find_files<cr>",                          desc = "Find Files (root dir)" },
      { "<leader>:",          "<cmd>Telescope command_history<cr>",                     desc = "Command History" },
      { "<a-space><a-space>", "<cmd>Telescope builtin<cr>",                             desc = "Telescope Builtins" },
      { "<leader>fb",         "<cmd>Telescope buffers<cr>",                             desc = "Buffers" },
      { "<leader>ff",         Util.telescope("files"),                                  desc = "Find Files (root dir)" },
      { "<leader>fF",         Util.telescope("files", { cwd = false }),                 desc = "Find Files (cwd)" },
      { "<leader>r",          "<cmd>Telescope oldfiles cwd_only=true<cr>",              desc = "Recent" },
      { "<leader>gc",         "<cmd>Telescope git_commits<CR>",                         desc = "commits" },
      { "<leader>gs",         "<cmd>Telescope git_status<CR>",                          desc = "status" },
      { "<leader>sa",         "<cmd>Telescope autocommands<cr>",                        desc = "Auto Commands" },
      { "<leader>sb",         "<cmd>Telescope current_buffer_fuzzy_find<cr>",           desc = "Buffer" },
      { "<leader>sc",         "<cmd>Telescope command_history<cr>",                     desc = "Command History" },
      { "<leader>sC",         "<cmd>Telescope commands<cr>",                            desc = "Commands" },
      { "<leader>sd",         "<cmd>Telescope diagnostics<cr>",                         desc = "Diagnostics" },
      { "<leader>sg",         Util.telescope("live_grep"),                              desc = "Grep (root dir)" },
      { "<leader>sG",         Util.telescope("live_grep", { cwd = false }),             desc = "Grep (cwd)" },
      { "<leader>sh",         "<cmd>Telescope help_tags<cr>",                           desc = "Help Pages" },
      { "<leader>sH",         "<cmd>Telescope highlights<cr>",                          desc = "Search Highlight Groups" },
      { "<leader>sk",         "<cmd>Telescope keymaps<cr>",                             desc = "Key Maps" },
      { "<leader>sM",         "<cmd>Telescope man_pages<cr>",                           desc = "Man Pages" },
      { "<leader>sm",         "<cmd>Telescope marks<cr>",                               desc = "Jump to Mark" },
      { "<leader>so",         "<cmd>Telescope vim_options<cr>",                         desc = "Options" },
      { "<leader>sw",         Util.telescope("grep_string"),                            desc = "Word (root dir)" },
      { "<leader>sW",         Util.telescope("grep_string", { cwd = false }),           desc = "Word (cwd)" },
      { "<leader>uC",         Util.telescope("colorscheme", { enable_preview = true }), desc = "Colorscheme with preview" },
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
    dependencies = {
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build =
        'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build'
      },
      "nvim-telescope/telescope-live-grep-args.nvim",
      "LinArcX/telescope-command-palette.nvim",
      "folke/trouble.nvim",
    },
    config = function()
      local telescope = require("telescope")
      local actions = require("telescope.actions")
      local trouble = require("trouble.providers.telescope")
      local lga_actions = require("telescope-live-grep-args.actions")

      local dropdown_opts = {
        theme = "dropdown",
        previewer = false,
        -- find_command = {
        --   'fd',
        --   '--type',
        --   'f',
        --   '--no-ignore-vcs',
        --   '--color=never',
        --   '--hidden',
        --   '--follow',
        -- }
      }

      local minimal = {
        theme = "minimal",
        layout_strategy = "horizontal",
        layout_config = {
          -- prompt_position = "bottom",
          width = 200,
          height = 35,
          -- preview_height = 25,
        },
        disable_devicons = true,
        prompt_title = "",
        results_title = "",
        preview_title = "",
        find_command = {
          'fd',
          '--type',
          'f',
          '--hidden',
        }
      }

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
          theme = minimal,
          path_display = { "truncate" },
          results_title = false,
          layout_strategy = "horizontal",
          layout_config = {
            vertical = {
              width = 0.9,
              height = 0.9,
              preview_height = 0.6,
              prompt_position = "top",
              preview_position = "bottom",
              mirror = true
            },
            horizontal = { width = 0.9, height = 0.9, preview_width = 0.6, prompt_position = "top" },
          },
          sorting_strategy = "ascending",
          file_ignore_patterns = { "node_modules/.*" },
          mappings = {
            i = {
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
              ["<C-d>"] = actions.delete_buffer,
              ["<C-f>"] = actions.preview_scrolling_down,
              ["<C-b>"] = actions.preview_scrolling_up,
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
          git_files = dropdown_opts,
          find_files = dropdown_opts,
          live_grep = minimal,
          help_tags = dropdown_opts,
          oldfiles = dropdown_opts,
        },
        extensions = {
          command_palette = {
            { "Jest",
              { "Run last test(s)",                 ':lua require"jester".run_last()' },
              { "Run current file",                 ':lua require"jester".run_file()' },
              { "Run nearest test(s) under cursor", ':lua require"jester".run()' },
            },
            { "Telescope",
              { "Builtins", 'Telescope builtin' },
            },
          },
          live_grep_args = {
            auto_quoting = true, -- enable/disable auto-quoting
            -- define mappings, e.g.
            mappings = {
              -- extend mappings
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
          fzf = {
            fuzzy = true,                   -- false will only do exact matching
            override_generic_sorter = true, -- override the generic sorter
            override_file_sorter = true,    -- override the file sorter
            case_mode = "smart_case",       -- or "ignore_case" or "respect_case"
          }
        },
      })
      telescope.load_extension("fzf")
      telescope.load_extension("live_grep_args")
      telescope.load_extension('command_palette')
    end,
  },
  {
    "sindrets/diffview.nvim",
    dependencies = "nvim-lua/plenary.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory" },
    keys = {
      { "<leader>gdp", "<cmd>DiffviewOpen<cr>",          desc = "Diff Project" },
      { "<leader>gdf", "<cmd>DiffviewFileHistory<cr>",   desc = "Diff File" },
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

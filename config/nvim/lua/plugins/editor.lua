return {
  {
    "lewis6991/gitsigns.nvim",
    event = "BufReadPre",
    opts = {
      signs = {
        add = { text = "│" },
        change = { text = "│" },
        delete = { text = "│" },
        topdelete = { text = "│" },
        changedelete = { text = "│" },
        untracked = { text = "│" },
        -- add = { text = "" },
        -- change = { text = "│" },
        -- delete = { text = "_" },
        -- topdelete = { text = "‾" },
        -- changedelete = { text = "~" },
        -- untracked = { text = "┆" },
      },
    },
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
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
    "declancm/cinnamon.nvim",
    opts = {
      hide_cursor = true,
      centered = true, -- keep lines centered
      default_delay = 4, -- 4ms between each line (a bit faster than default of 7)
    },
  },
  {
    "stevearc/aerial.nvim",
    config = function()
      require("aerial").setup({
        -- optionally use on_attach to set keymaps when aerial has attached to a buffer
        on_attach = function(bufnr)
          -- Jump forwards/backwards with '{' and '}'
          vim.keymap.set("n", "{", "<cmd>AerialPrev<CR>", { buffer = bufnr })
          vim.keymap.set("n", "}", "<cmd>AerialNext<CR>", { buffer = bufnr })
        end,
      })
    end,
  },
  {
    "liangxianzhe/nap.nvim",
    dependencies = { "stevearc/aerial.nvim", "lewis6991/gitsigns.nvim" },
    lazy = false,
    opts = {
      next_prefix = "<C-n>",
      prev_prefix = "<C-p>",
      next_repeat = "<cr>",
      prev_repeat = "<c-cr>",
    },
    config = function(_, opts)
      require("nap").setup(opts)
      require("nap").nap("h", "Gitsigns next_hunk", "Gitsigns prev_hunk", "Next diff", "Previous diff")
      require("nap").nap("o", "AerialNext", "AerialPrev", "Next outline symbol", "Previous outline symbol")
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
  },

  {
    "ibhagwan/fzf-lua",
    enabled = false,
    cmd = {
      "FzfLua",
    },
    keys = {
      { "<leader>,", "<cmd>lua require'fzf-lua'.buffers()<cr>", desc = "Switch Buffer" },
      { "<leader>/", "<cmd>lua require'fzf-lua'.live_grep_native()<cr>", desc = "Find in Files (Grep)" },
      { "<leader>:", "<cmd>lua require'fzf-lua'.command_history()<cr>", desc = "Command History" },
      { "<leader><space>", "<cmd>lua require'fzf-lua'.files()<cr>", desc = "Find Files" },
      -- find
      -- { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
      -- { "<leader>ff", Util.telescope("files"), desc = "Find Files (root dir)" },
      -- { "<leader>fF", Util.telescope("files", { cwd = false }), desc = "Find Files (cwd)" },
      { "<leader>fo", "<cmd>lua require'fzf-lua'.oldfiles()<cr>", desc = "Old Files" },
      -- lsp
      { "gd", "<cmd>lua require'fzf-lua'.lsp_definitions()<cr>", desc = "commits" },
      -- -- git
      { "<leader>gc", "<cmd>lua require'fzf-lua'.git_commits()<cr>", desc = "commits" },
      { "<leader>gs", "<cmd>lua require'fzf-lua'.git_status()<cr>", desc = "status" },
      -- -- search
      -- { "<leader>sa", "<cmd>Telescope autocommands<cr>", desc = "Auto Commands" },
      -- { "<leader>sb", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Buffer" },
      -- { "<leader>sc", "<cmd>Telescope command_history<cr>", desc = "Command History" },
      { "<leader>sC", "<cmd>lua require'fzf-lua'.commands()<cr>", desc = "Commands" },
      { "<leader>sd", "<cmd>lua require'fzf-lua'.diagnostics_document()<cr>", desc = "Diagnostics (Document)" },
      { "<leader>sD", "<cmd>lua require'fzf-lua'.diagnostics_workspace()<cr>", desc = "Diagnostics (Workspace)" },
      -- { "<leader>sg", Util.telescope("live_grep"), desc = "Grep (root dir)" },
      -- { "<leader>sG", Util.telescope("live_grep", { cwd = false }), desc = "Grep (cwd)" },
      { "<leader>sh", "<cmd>lua require'fzf-lua'.help_tags()<cr>", desc = "Help Tags" },
      { "<leader>sH", "<cmd>lua require'fzf-lua'.highlights()<cr>", desc = "Search Highlight Groups" },
      { "<leader>sk", "<cmd>lua require'fzf-lua'.keymaps()<cr>", desc = "Key Maps" },
      -- { "<leader>sM", "<cmd>Telescope man_pages<cr>", desc = "Man Pages" },
      -- { "<leader>sm", "<cmd>Telescope marks<cr>", desc = "Jump to Mark" },
      -- { "<leader>so", "<cmd>Telescope vim_options<cr>", desc = "Options" },
      { "<leader>sw", "<cmd>lua require'fzf-lua'.grep_cword()<cr>", desc = "Word" },
      -- { "<leader>sW", Util.telescope("grep_string", { cwd = false }), desc = "Word (cwd)" },
      { "<leader>uC", "<cmd>lua require'fzf-lua'.colorschemes()<cr>", desc = "Colorscheme with preview" },
      { "<leader>xx", "<cmd>lua require'fzf-lua'.diagnostics_document()<cr>", desc = "Document Diagnostics" },
      { "<leader>xX", "<cmd>lua require'fzf-lua'.diagnostics_workspace()<cr>", desc = "Workspace Diagnostics" },
      -- {
      --   "<leader>ss",
      --   Util.telescope("lsp_document_symbols", {
      --     symbols = {
      --       "Class",
      --       "Function",
      --       "Method",
      --       "Constructor",
      --       "Interface",
      --       "Module",
      --       "Struct",
      --       "Trait",
      --       "Field",
      --       "Property",
      --     },
      --   }),
      --   desc = "Goto Symbol",
      -- },
    },
    -- optional for icon support
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },
  {
    "nvim-telescope/telescope.nvim",
    keys = {
      { "<leader><leader>", false },
    },
    dependencies = { { "nvim-telescope/telescope-fzf-native.nvim", build = "make" }, "folke/trouble.nvim", "nvim-telescope/telescope-live-grep-args.nvim" },
    -- apply the config and additionally load fzf-native
    config = function()
      local telescope = require("telescope")
      local builtin = require("telescope.builtin")
      local actions = require("telescope.actions")
      local trouble = require("trouble.providers.telescope")
      local lga_actions = require("telescope-live-grep-args.actions")

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
          },
          prompt_prefix = "❯ ",
          selection_caret = "❯ ",
          -- layout_strategy = "vertical",
          -- layout_strategy = "horizontal",
          -- layout_config = {
          --   vertical = { width = 0.9, height = 0.9, preview_height = 0.6 },
          --   horizontal = { width = 0.9, height = 0.9, preview_width = 0.6, prompt_position = "top" },
          -- },
          layout_config = { prompt_position = "top" },
          sorting_strategy = "ascending",
          winblend = 5,
          prompt_position = "top",
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
        extensions = {
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
        },
      })
      telescope.load_extension("fzf")
      telescope.load_extension("live_grep_args")
    end,
  },
  {
    "sindrets/diffview.nvim",
    dependencies = "nvim-lua/plenary.nvim",
    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diff Project" },
      { "<leader>gh", "<cmd>DiffviewFileHistory<cr>", desc = "aoeu" },
      { "<leader>gH", "<cmd>DiffviewFileHistory %<cr>", desc = "aoeu" },
    },

    config = function()
      require("diffview").setup({
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
      })
    end,
  },
}

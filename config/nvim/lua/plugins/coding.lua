return {
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-emoji",
      "hrsh7th/cmp-cmdline",
    },
    ---@param opts cmp.ConfigSchema
    opts = function(_, opts)
      local luasnip = require("luasnip")
      local cmp = require("cmp")

      opts.completion = {
        completeopt = "menu,menuone,noselect,preview", -- @ref :h 'completeopt'
        -- completeopt = "menu,menuone,noinsert",
      }

      opts.experimental = {
        ghost_text = false  
      }

      opts.mapping = vim.tbl_extend("force", opts.mapping, {
        ["<CR>"] = cmp.mapping.confirm({ select = false }),
        ["<S-CR>"] = cmp.mapping.confirm({ select = true }),
        ["<Tab>"] = cmp.mapping(function(fallback)
          -- gonna try out using tab only for snippets, since I'm so used to ctrl-n and ctrl-p for nav
          -- if cmp.visible() then
          --   cmp.select_next_item()
          --   -- You could replace the expand_or_jumpable() calls with expand_or_locally_jumpable()
          --   -- they way you will only jump inside the snippet region
          -- else
          if luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
            -- elseif has_words_before() then
            --   cmp.complete()
          else
            fallback()
          end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
          -- if cmp.visible() then
          --   cmp.select_prev_item()
          -- else
          if luasnip.jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { "i", "s" }),
      })

      opts.sources = cmp.config.sources(vim.list_extend(opts.sources, { { name = "emoji" }, { name = "cmdline" } }))
      opts.window = {
        completion = {
          -- rounded border; thin-style scrollbar
          border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
          winhighlight = "Normal:CmpPmenu,FloatBorder:CmpPmenuBorder,CursorLine:PmenuSel,Search:None",
        },
        documentation = {
          -- no border; native-style scrollbar
          border = "rounded",
          winhighlight = "Normal:CmpPmenu,FloatBorder:CmpPmenuBorder,CursorLine:PmenuSel,Search:None",
        },
      }
    end,
    config = function(_, opts)
      require("cmp").setup(opts)
      require("cmp").setup.cmdline(":", {
        mapping = require("cmp").mapping.preset.cmdline(),
        sources = require("cmp").config.sources({
          { name = "path" },
        }, {
          {
            name = "cmdline",
            option = {
              ignore_cmds = { "Man", "!" },
            },
          },
        }),
      })
    end,
  },
  {
    "abecodes/tabout.nvim",
    dependencies = { "nvim-treesitter", "nvim-cmp" },
    opts = {
      {
        tabkey = "<Tab>", -- key to trigger tabout, set to an empty string to disable
        backwards_tabkey = "<S-Tab>", -- key to trigger backwards tabout, set to an empty string to disable
        act_as_tab = true, -- shift content if tab out is not possible
        act_as_shift_tab = false, -- reverse shift content if tab out is not possible (if your keyboard/terminal supports <S-Tab>)
        default_tab = "<C-t>", -- shift default action (only at the beginning of a line, otherwise <TAB> is used)
        default_shift_tab = "<C-d>", -- reverse shift default action,
        enable_backwards = true, -- well ...
        completion = true, -- if the tabkey is used in a completion pum
        tabouts = {
          { open = "'", close = "'" },
          { open = '"', close = '"' },
          { open = "`", close = "`" },
          { open = "(", close = ")" },
          { open = "[", close = "]" },
          { open = "{", close = "}" },
        },
        ignore_beginning = true, --[[ if the cursor is at the beginning of a filled element it will rather tab out than shift the content ]]
        exclude = {}, -- tabout will ignore these filetypes
      },
    },
  },
  {
    "echasnovski/mini.surround",
    enabled = false,
  },
  { "tpope/vim-surround" },
  {
    "David-Kunz/jester",
    lazy = false,
    opts = {
      -- terminal_cmd = ":vsplit | terminal", -- used to spawn a terminal for running tests,
      terminal_cmd = ":lua require('lazyvim.util').float_term()", -- used to spawn a terminal for running tests,
    },
  },
}

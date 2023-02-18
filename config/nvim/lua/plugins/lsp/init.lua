return {
  { import = "lazyvim.plugins.extras.lang.typescript" },
  -- add any tools you want to have installed below
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "bash-language-server",
        "codelldb",
        "cpptools",
        "editorconfig-checker",
        "flake8",
        "gopls",
        "graphql-language-service-cli",
        "html-lsp",
        "lua-language-server",
        "luacheck",
        "misspell",
        "prettierd",
        "pyright",
        "rust-analyzer",
        "rustfmt",
        "shellcheck",
        "shellcheck",
        "shfmt",
        "shfmt",
        "stylua",
        "stylua",
        "tailwindcss-language-server",
        "typescript-language-server",
        "xo",
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    init = function()
      local keys = require("lazyvim.plugins.lsp.keymaps").get()
      -- change a keymap
      keys[#keys + 1] = { "gd", "<cmd>FzfLua lsp_definitions<cr>" }
      keys[#keys + 1] = { "gr", "<cmd>FzfLua lsp_references<cr>" }
      keys[#keys + 1] = { "gI", "<cmd>FzfLua lsp_implementations<cr>" }
      keys[#keys + 1] = { "gt", "<cmd>FzfLua lsp_typedefs<cr>" }
      -- disable a keymap
      -- keys[#keys + 1] = { "K", false }

      -- @source :h diagnostic-handlers-example
      -- Create a custom namespace. This will aggregate signs from all other
      -- namespaces and only show the one with the highest severity on a
      -- given line
      local ns = vim.api.nvim_create_namespace("my_namespace")

      -- Get a reference to the original signs handler
      local orig_signs_handler = vim.diagnostic.handlers.signs

      -- Override the built-in signs handler
      vim.diagnostic.handlers.signs = {
        show = function(_, bufnr, _, opts)
          -- Get all diagnostics from the whole buffer rather than just the
          -- diagnostics passed to the handler
          local diagnostics = vim.diagnostic.get(bufnr)

          -- Find the "worst" diagnostic per line
          local max_severity_per_line = {}
          for _, d in pairs(diagnostics) do
            local m = max_severity_per_line[d.lnum]
            if not m or d.severity < m.severity then
              max_severity_per_line[d.lnum] = d
            end
          end

          -- Pass the filtered diagnostics (with our custom namespace) to
          -- the original handler
          local filtered_diagnostics = vim.tbl_values(max_severity_per_line)
          orig_signs_handler.show(ns, bufnr, filtered_diagnostics, opts)
        end,
        hide = function(_, bufnr)
          orig_signs_handler.hide(ns, bufnr)
        end,
      }
    end,
    ---@class PluginLspOpts
    opts = {
      diagnostics = {
        float = {
          border = "rounded",
        },
      },
      ---@type lspconfig.options
      servers = {
        -- pyright will be automatically installed with mason and loaded with lspconfig
        lua_ls = {
          settings = {
            Lua = {
              diagnostics = {
                globals = {
                  "vim",
                  "use",
                  "describe",
                  "it",
                  "assert",
                  "before_each",
                  "after_each",
                },
              },
              workspace = {
                checkThirdParty = false,
              },
              completion = {
                callSnippet = "Replace",
              },
            },
          },
        },
      },
    },
  },
}

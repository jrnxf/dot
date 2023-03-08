return {
  { import = "lazyvim.plugins.extras.lang.typescript" },
  -- add any tools you want to have installed below
  {
    "jose-elias-alvarez/null-ls.nvim",
    event = "BufReadPre",
    dependencies = { "mason.nvim" },
    opts = function()
      local nls = require("null-ls")
      return {
        sources = {
          nls.builtins.formatting.prettierd,
          nls.builtins.diagnostics.xo.with({
            cwd = vim.loop.cwd(),
          }),
          nls.builtins.code_actions.xo,
          nls.builtins.code_actions.gitsigns,
          -- nls.builtins.formatting.prettier,
        },
        border = "rounded",
        debug = true,
      }
    end,
  },
  {
    "williamboman/mason.nvim",
    opts = {
      ui = {
        border = "rounded",
        width = 0.8,
        height = 0.8,
      },
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
        "shfmt",
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
      -- keys[#keys + 1] = { "gd", "<cmd>FzfLua lsp_definitions<cr>" }
      -- keys[#keys + 1] = { "gr", "<cmd>FzfLua lsp_references<cr>" }
      -- keys[#keys + 1] = { "gI", "<cmd>FzfLua lsp_implementations<cr>" }
      -- keys[#keys + 1] = { "gt", "<cmd>FzfLua lsp_typedefs<cr>" }
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
    opts = function(_, opts)
      require("lspconfig.ui.windows").default_options.border = "rounded"

      opts.diagnostics.float = {
        border = "rounded",
      }

      opts.servers.lua_ls.settings.Lua.diagnostics = {
        globals = {
          "vim",
          "use",
          "describe",
          "it",
          "assert",
          "before_each",
          "after_each",
        },
      }

      local util = require("lspconfig.util")

      -- @credit https://github.com/letieu/nvim-config/blob/master/lua/plugins/lsp/bun.lua
      local bun_servers = { "eslint", "tsserver", "html", "cssls", "tailwindcss" }

      local function is_bun_server(name)
        for _, server in ipairs(bun_servers) do
          if server == name then
            return true
          end
        end
        return false
      end

      local function is_bun_available()
        local bunx = vim.fn.executable("bunx")
        if bunx == 0 then
          return false
        end
        return true
      end

      util.on_setup = util.add_hook_before(util.on_setup, function(config, _)
        if config.cmd and is_bun_available() and is_bun_server(config.name) then
          config.cmd = vim.list_extend({ "bunx" }, config.cmd)
        end
      end)
    end,
  },
}

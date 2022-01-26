return function()
  local lspconfig_ok, lspconfig = safe_require 'lspconfig'
  local lsp_installer_ok, lsp_installer = safe_require 'nvim-lsp-installer'
  local null_ls_ok, null_ls = safe_require 'null-ls'

  if not lspconfig_ok or not lsp_installer_ok or not null_ls_ok then
    print("Error requiring deps for lsp/init.lua")
    return
  end

  local on_attach = require 'lsp.on-attach'
  -- Register a handler that will be called for each installed server when it's ready
  -- (i.e. when installation is finished or if the server is already installed).
  lsp_installer.on_server_ready(function(server)
      print(server.name .. " lsp is ready")
      local opts = {
        -- handlers = handlers
        on_attach = on_attach
      }


      -- (optional) Customize the options passed to the server
      -- if server.name == "tsserver" then
      --     opts.root_dir = function() ... end
      -- end

      -- This setup() function will take the provided server configuration and decorate it with the necessary properties
      -- before passing it onwards to lspconfig.
      -- Refer to https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
      server:setup(opts)
  end)

  null_ls.setup({
    sources = {
        null_ls.builtins.diagnostics.eslint,
        null_ls.builtins.code_actions.eslint,
        null_ls.builtins.formatting.prettier,
    },
    on_attach = on_attach,
  })
end

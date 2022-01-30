return function()
  local lsp_installer = require 'nvim-lsp-installer'
  local null_ls = require 'null-ls'


local border_opts = { border = "single", focusable = false, scope = "line" }

vim.diagnostic.config({ virtual_text = false, float = border_opts })

local lsp = vim.lsp
lsp.handlers["textDocument/signatureHelp"] = lsp.with(lsp.handlers.signature_help, border_opts)
lsp.handlers["textDocument/hover"] = lsp.with(lsp.handlers.hover, border_opts)

local on_attach = require 'lsp.on-attach'
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").update_capabilities(capabilities)


-- Register a handler that will be called for each installed server when it's ready
-- (i.e. when installation is finished or if the server is already installed).
lsp_installer.on_server_ready(function(server)
    -- vim.notify(server.name .. " lsp is ready", vim.log.levels.DEBUG)
    local opts = {
      on_attach = on_attach,
      capabilities = capabilities
    }


    if server.name == "sumneko_lua" then
        opts = require('lsp.sumneko_lua').opts(on_attach, capabilities)
    end

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

local M = {}

M.getOpts = function(on_attach, capabilities)
  local opts = {
    root_dir = require('lspconfig').util.root_pattern('.eslintrc', '.eslintrc.js'),
    on_attach = function(client, bufnr)
      client.resolved_capabilities.document_formatting = true
      on_attach(client, bufnr)
asdfasdf    end,
    capabilities = capabilities,
    settings = {
      format = {
        enable = true,
      },
    },
  }
  return opts
end

return M

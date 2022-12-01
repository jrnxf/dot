local M = {}

M.setup = function(on_attach, capabilities, utils)
  require('lspconfig').gopls.setup({
    on_attach = function(client, bufnr)
      on_attach(client, bufnr)
      utils.enable_formatting(bufnr)
    end,
    capabilities = capabilities,
  })
end

return M

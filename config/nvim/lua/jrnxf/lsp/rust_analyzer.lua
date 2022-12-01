local M = {}

M.setup = function(on_attach, capabilities)
  require('lspconfig').rust_analyzer.setup({
    on_attach = on_attach,
    capabilities = capabilities,
    settings = {
      ['rust-analyzer'] = {
        checkOnSave = {
          allFeatures = true,
          overrideCommand = {
            'cargo',
            'clippy',
            '--workspace',
            '--message-format=json',
            '--all-targets',
            '--all-features',
          },
        },
      },
    },
  })
end

return M

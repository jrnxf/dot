local M = { 
  setup = function(on_attach, capabilities)
    require('lspconfig').sumneko_lua.setup({
      on_attach = on_attach,
      settings = {

        Lua = {
          diagnostics = {
            globals = {
              'global',
              'vim',
              'use',
              'describe',
              'it',
              'assert',
              'before_each',
              'after_each',
            },
          },
          completion = {
            showWord = 'Disable',
            callSnippet = 'Disable',
            keywordSnippet = 'Disable',
          },
        },
      },
      flags = {
        debounce_text_changes = 150,
      },
      capabilities = capabilities,
    })
  end
}
return M

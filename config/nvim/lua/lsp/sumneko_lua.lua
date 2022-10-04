local settings = {
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
}

local M = {}

M.getOpts = function(on_attach, capabilities)
  local luadev = require('lua-dev').setup {
    lspconfig = {

      on_attach = function(client, bufnr)
        on_attach(client, bufnr)

        -- we only want null_ls to format
        client.server_capabilities.document_formatting = false
        client.server_capabilities.document_range_formatting = false
      end,

      capabilities = capabilities,

      settings = settings,
      flags = {
        debounce_text_changes = 150,
      },
    },
  }
  return luadev
end

return M

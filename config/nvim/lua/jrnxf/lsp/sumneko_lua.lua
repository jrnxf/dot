local settings = {
  Lua = {
    diagnostics = {
      globals = {
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
    workspace = {
      library = vim.api.nvim_get_runtime_file('', true),
      checkThirdParty = false,
    },
    telemetry = {
      enable = false,
    },
  },
}

local M = {}

M.setup = function(on_attach, capabilities)
  require('neodev').setup({
    override = function(root_dir, library)
      if root_dir:match('dotfiles') then
        library.enabled = true
        library.plugins = true
      end
    end,
  })

  require('lspconfig').sumneko_lua.setup({
    on_attach = on_attach,
    settings = settings,
    flags = {
      debounce_text_changes = 150,
    },
    capabilities = capabilities,
  })
end

return M

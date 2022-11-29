local u = require('jrnxf.core.utils')
local nvim_lsp = require('lspconfig')
local null_ls = require('null-ls')

local lsp = vim.lsp

local border_opts = { border = 'rounded', focusable = false, scope = 'line' }

require('lspconfig.ui.windows').default_options = { border = 'rounded' } -- styles windows from nvim-lspconfig (e.g. :LSPInfo)

vim.diagnostic.config({ virtual_text = false, float = border_opts })

lsp.handlers['textDocument/signatureHelp'] = lsp.with(lsp.handlers.signature_help, border_opts)
lsp.handlers['textDocument/hover'] = lsp.with(lsp.handlers.hover, border_opts)

local nlsb = null_ls.builtins

-- serves as a reusable autogroup for all lsp formatting commands
local augroup_lsp_formatting = vim.api.nvim_create_augroup('LspFormatting', {})

local enable_format_on_save = function(bufnr, callback)
  callback = callback or function()
    vim.lsp.buf.format({ bufnr = bufnr })
  end
  -- clears any existing autocommands that exist under the given autogroup
  -- (i.e. the LspFormatting one defined above) and provided bufnr, since
  -- we don't want duplicates
  vim.api.nvim_clear_autocmds({ group = augroup_lsp_formatting, buffer = bufnr })
  vim.api.nvim_create_autocmd('BufWritePre', {
    group = augroup_lsp_formatting,
    buffer = bufnr,
    callback = callback,
  })
end

-- triggered when an lsp client attaches on a buffer
---@diagnostic disable-next-line: unused-local
local base_on_attach = function(client, bufnr)
  u.buf_map(bufnr, 'n', 'ga', ':LspCodeAction<CR>')
  u.buf_map(bufnr, 'n', 'K', ':LspHover<CR>')
  u.buf_map(bufnr, 'n', '<leader>rn', ':LspRename<CR>')
  u.buf_map(bufnr, 'n', '<leader>e', ':LspDiagFloat<CR>')
  u.buf_map(bufnr, 'n', '<leader>fo', ':LspFormatting<CR>')
end

local capabilities = require('cmp_nvim_lsp').default_capabilities() -- TODO: eval differences here between above

nvim_lsp.prismals.setup({})

nvim_lsp.eslint.setup({
  capabilities = capabilities,
  on_attach = function(client, bufnr)
    base_on_attach(client, bufnr)
    client.server_capabilities.documentFormattingProvider = true
  end,
  root_dir = nvim_lsp.util.root_pattern('.eslintrc', '.eslintrc.js', '.eslintrc.json'),
  settings = { format = { enable = true } },
})

-- TODO: eval to see if the tsserver is enough or if Jose's plugin is preferrable
-- https://github.com/jose-elias-alvarez/typescript.nvim

nvim_lsp.tsserver.setup({
  capabilities = capabilities,
  on_attach = base_on_attach,
  filetypes = { 'typescript', 'typescriptreact', 'typescript.tsx' },
  cmd = { 'typescript-language-server', '--stdio' },
})

nvim_lsp.sumneko_lua.setup({
  capabilities = capabilities,
  on_attach = function(client, bufnr)
    base_on_attach(client, bufnr)
    enable_format_on_save(bufnr)
  end,
  settings = {
    Lua = {
      diagnostics = {
        -- Get the language server to recognize the `vim` global
        globals = { 'vim' },
      },
      workspace = {
        -- Make the server aware of Neovim runtime files
        library = vim.api.nvim_get_runtime_file('', true),
        checkThirdParty = false,
      },
    },
  },
})

nvim_lsp.rust_analyzer.setup({
  on_attach = base_on_attach,
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

nvim_lsp.gopls.setup({
  on_attach = function(client, bufnr)
    base_on_attach(client, bufnr)
    enable_format_on_save(bufnr)
    -- if the above enable_format_on_save doesn't work, then rewrite the
    -- command below as a nvim_create_autocmd instead under the same augroup
    -- defined above
    -- vim.cmd('au BufWritePre <buffer> lua require"go.format".gofmt()')
  end,
  capabilities = capabilities,
})

null_ls.setup({
  debug = true,
  sources = {
    -- formatting
    nlsb.formatting.prettierd,
    nlsb.formatting.stylua,
    -- code actions
    nlsb.code_actions.gitsigns,
    nlsb.code_actions.gitrebase,
  },
  on_attach = function(client, bufnr)
    if client.supports_method('textDocument/formatting') then
      enable_format_on_save(bufnr, function()
        vim.lsp.buf.format({
          filter = function(_client)
            return _client.name == 'null-ls'
          end,
          bufnr = bufnr,
        })
      end)
    end
  end,
})

vim.lsp.handlers['textDocument/publishDiagnostics'] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
  underline = true,
  update_in_insert = false,
  virtual_text = false, -- disables inline buffer lsp messages
  severity_sort = true,
})

-- Diagnostic symbols in the sign column (gutter)
local signs = { Error = ' ', Warn = ' ', Hint = ' ', Info = ' ' }
for type, icon in pairs(signs) do
  local hl = 'DiagnosticSign' .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = '' })
end

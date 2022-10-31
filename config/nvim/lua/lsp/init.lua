local u = require('core.utils')

local lsp = vim.lsp

local border_opts = {
  border = 'single',
  focusable = false,
  scope = 'line',
}

vim.diagnostic.config({
  virtual_text = false,
  float = border_opts,
})

lsp.handlers['textDocument/signatureHelp'] = lsp.with(lsp.handlers.signature_help, border_opts)
lsp.handlers['textDocument/hover'] = lsp.with(lsp.handlers.hover, border_opts)

local km = require('core.keymaps')

local augroup = vim.api.nvim_create_augroup('LspFormatting', {})

local lsp_formatting = function(bufnr)
  lsp.buf.format({ bufnr = bufnr })
end

-- triggered when an lsp client attaches on a buffer
local on_attach = function(client, bufnr)
  u.buf_map(bufnr, 'i', '<C-k>', ':LspSignatureHelp<CR>')
  u.buf_map(bufnr, 'n', 'gD', ':LspDeclaration<CR>')
  u.buf_map(bufnr, 'n', 'ga', ':LspCodeAction<CR>')
  u.buf_map(bufnr, 'n', 'K', ':LspHover<CR>')
  u.buf_map(bufnr, 'n', '<leader>rn', ':LspRename<CR>')
  u.buf_map(bufnr, 'n', '<leader>e', ':LspDiagFloat<CR>')
  u.buf_map(bufnr, 'n', '[d', ':LspDiagPrev<CR>')
  u.buf_map(bufnr, 'n', ']d', ':LspDiagNext<CR>')
  u.buf_map(bufnr, 'n', 'gd', ':LspDefinition<CR>')
  u.buf_map(bufnr, 'n', 'gt', ':LspTypeDefinition<CR>')
  u.buf_map(bufnr, 'n', 'gr', ':LspReferences<CR>')
  u.buf_map(bufnr, 'n', 'gi', ':LspImplementation<CR>')
  u.buf_map(bufnr, 'n', '<leader>qf', ':LspDiagQuickfix<CR>')
  u.buf_map(bufnr, 'n', '<leader>ql', ':LspDiagLoclist<CR>')

  if client.supports_method('textDocument/formatting') then
    u.buf_command(bufnr, 'LspFormatting', function()
      lsp_formatting(bufnr)
    end)

    vim.api.nvim_clear_autocmds({
      group = augroup,
      buffer = bufnr,
    })
    vim.api.nvim_create_autocmd('BufWritePre', {
      group = augroup,
      buffer = bufnr,
      command = 'LspFormatting',
    })
  end
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
-- capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

for _, server in ipairs({
  'eslint',
  'null_ls',
  'sumneko_lua',
  'tsserver',
}) do
  require('lsp.' .. server).setup(on_attach, capabilities)
end

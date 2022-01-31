local border_opts = { border = 'single', focusable = false, scope = 'line' }
local lsp = vim.lsp

vim.diagnostic.config { virtual_text = false, float = border_opts }
lsp.handlers['textDocument/signatureHelp'] = lsp.with(lsp.handlers.signature_help, border_opts)
lsp.handlers['textDocument/hover'] = lsp.with(lsp.handlers.hover, border_opts)

local u = require 'core.utils'

-- triggered when an lsp client attaches on a buffer
local on_attach = function(client, bufnr)
  vim.cmd 'command! LspDeclaration lua vim.lsp.buf.declaration()'
  vim.cmd 'command! LspDefinition lua vim.lsp.buf.definition()'
  vim.cmd 'command! LspFormatting lua vim.lsp.buf.formatting()'
  vim.cmd 'command! LspCodeAction lua vim.lsp.buf.code_action()'
  vim.cmd 'command! LspHover lua vim.lsp.buf.hover()'
  vim.cmd 'command! LspRename lua vim.lsp.buf.rename()'
  vim.cmd 'command! LspReferences lua vim.lsp.buf.references()'
  vim.cmd 'command! LspTypeDefinition lua vim.lsp.buf.type_definition()'
  vim.cmd 'command! LspImplementation lua vim.lsp.buf.implementation()'
  vim.cmd 'command! LspSignatureHelp lua vim.lsp.buf.signature_help()'
  vim.cmd 'command! LspDiagQuickfix lua vim.diagnostic.setqflist()'
  vim.cmd 'command! LspDiagPrev lua vim.diagnostic.goto_prev()'
  vim.cmd 'command! LspDiagNext lua vim.diagnostic.goto_next()'
  vim.cmd 'command! LspDiagLine lua vim.diagnostic.open_float()'

  u.buf_map(bufnr, 'n', 'gD', ':LspDeclaration<CR>')
  u.buf_map(bufnr, 'n', 'gd', ':LspDefinition<CR>')
  u.buf_map(bufnr, 'n', 'gt', ':LspTypeDefinition<CR>')
  u.buf_map(bufnr, 'n', 'gr', ':LspReferences<CR>')
  u.buf_map(bufnr, 'n', 'gi', ':LspImplementation<CR>')
  u.buf_map(bufnr, 'n', 'ga', ':LspCodeAction<CR>')
  u.buf_map(bufnr, 'n', 'K', ':LspHover<CR>')
  u.buf_map(bufnr, 'i', '<C-k>', ':LspSignatureHelp<CR>')
  u.buf_map(bufnr, 'n', '<Leader>rn', ':LspRename<CR>')
  u.buf_map(bufnr, 'n', '<Leader>a', ':LspDiagLine<CR>')
  u.buf_map(bufnr, 'n', '<Leader>q', ':LspDiagQuickfix<CR>')
  u.buf_map(bufnr, 'n', '[a', ':LspDiagPrev<CR>')
  u.buf_map(bufnr, 'n', ']a', ':LspDiagNext<CR>')

  if client.resolved_capabilities.document_formatting then
    vim.cmd 'au BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()'
  end
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

local lsp_installer = require 'nvim-lsp-installer'

lsp_installer.on_server_ready(function(server)
  local opts = {
    on_attach = on_attach,
    capabilities = capabilities,
  }

  -- custom server configurations
  if server.name == 'eslint' or server.name == 'sumneko_lua' or server.name == 'tsserver' then
    opts = require('lsp.' .. server.name).getOpts(on_attach, capabilities)
  end

  server:setup(opts)
end)

-- null_ls isn't really a language server, so we setup manually
require('lsp.null_ls').setup(on_attach)

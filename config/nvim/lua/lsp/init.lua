-- NOTES
-- for rust, make sure you have all rust-related tools installed
-- https://rustup.rs/

local lsp = vim.lsp
local border_opts = { border = 'single', focusable = false, scope = 'line' }

vim.diagnostic.config { virtual_text = false, float = border_opts }
lsp.handlers['textDocument/signatureHelp'] = lsp.with(lsp.handlers.signature_help, border_opts)
lsp.handlers['textDocument/hover'] = lsp.with(lsp.handlers.hover, border_opts)

local km = require 'core.keymaps'

-- triggered when an lsp client attaches on a buffer
local on_attach = function(client, bufnr)
  km.set_buffer_lsp_maps(bufnr)

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
  if
    server.name == 'gopls'
    or server.name == 'eslint'
    or server.name == 'sumneko_lua'
    or server.name == 'tsserver'
    or server.name == 'efm'
  then
    opts = require('lsp.' .. server.name).getOpts(on_attach, capabilities)
  end

  server:setup(opts)
end)

-- null_ls isn't really a language server, so we setup manually
require('lsp.null_ls').setup(on_attach)

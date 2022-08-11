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

require('lsp.efm').getOpts(on_attach, capabilities)
require('lsp.eslint').getOpts(on_attach, capabilities)
require('lsp.gopls').getOpts(on_attach, capabilities)
require('lsp.null_ls').setup(on_attach)
require('lsp.rust_analyzer').getOpts(on_attach, capabilities)
require('lsp.sumneko_lua').getOpts(on_attach, capabilities)
require('lsp.tsserver').getOpts(on_attach, capabilities)

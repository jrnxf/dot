local ok = pcall(require, 'lspconfig')
if not ok then
  vim.notify('Skipping LSP setup as lspconfig is not yet installed/loaded')
  return
end

local u = require('jrnxf.core.utils')

local lsp = vim.lsp

local border_opts = { border = 'rounded', focusable = false, scope = 'line' }
-- noice handles signatureHelp and hover for us
-- lsp.handlers['textDocument/signatureHelp'] = lsp.with(lsp.handlers.signature_help, border_opts)
-- lsp.handlers['textDocument/hover'] = lsp.with(lsp.handlers.hover, border_opts)
vim.diagnostic.config({ float = border_opts })
require('lspconfig.ui.windows').default_options = { border = 'rounded' } -- styles windows from nvim-lspconfig (e.g. :LSPInfo)

lsp.handlers['textDocument/signatureHelp'] = lsp.with(lsp.handlers.signature_help, border_opts)
lsp.handlers['textDocument/hover'] = lsp.with(lsp.handlers.hover, border_opts)

lsp.handlers['textDocument/publishDiagnostics'] = lsp.with(lsp.diagnostic.on_publish_diagnostics, {
  underline = true,
  update_in_insert = false,
  virtual_text = true, -- redundant with lsp_lines ( but sometimes lsp_lines is mega annoying )
  severity_sort = true,
})

-- Diagnostic symbols in the sign column (gutter)
local signs = { Error = ' ', Warn = ' ', Hint = ' ', Info = ' ' }
for type, icon in pairs(signs) do
  local hl = 'DiagnosticSign' .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = '' })
end

-- utils represents nice-to-have methods that can be passed along to individual
-- server configs
local utils = {}

-- serves as a reusable autogroup for all lsp formatting commands
local augroup_lsp_formatting = vim.api.nvim_create_augroup('LspFormatting', {})

utils.enable_formatting = function(bufnr, cb)
  put('enabling formatting for bufnr:' .. bufnr)
  cb = cb or function()
    vim.lsp.buf.format({ bufnr = bufnr })
  end
  -- clears any existing autocommands that exist under the given autogroup
  -- (i.e. the LspFormatting one defined above) and provided bufnr, since
  -- we don't want duplicates
  vim.api.nvim_clear_autocmds({ group = augroup_lsp_formatting, buffer = bufnr })
  vim.api.nvim_create_autocmd('BufWritePre', {
    group = augroup_lsp_formatting,
    buffer = bufnr,
    callback = cb,
  })
  u.buf_command(bufnr, 'LspFormatting', cb)

  buf_map(bufnr, 'n', '<leader>fo', cb)
  buf_map(bufnr, 'x', '<CR>', cb)
end

local on_attach = function(client, bufnr)
  -- commands
  u.buf_command(bufnr, 'LspHover', lsp.buf.hover)
  u.buf_command(bufnr, 'LspDiagPrev', vim.diagnostic.goto_prev)
  u.buf_command(bufnr, 'LspDiagNext', vim.diagnostic.goto_next)
  u.buf_command(bufnr, 'LspDiagFloat', vim.diagnostic.open_float)
  u.buf_command(bufnr, 'LspSignatureHelp', lsp.buf.signature_help)
  u.buf_command(bufnr, 'LspCodeAction', lsp.buf.code_action)

  -- bindings
  buf_map(bufnr, 'n', '<leader>rn', function()
    return ':IncRename ' .. vim.fn.expand('<cword>')
  end, { expr = true })
  buf_map(bufnr, 'n', 'K', ':LspHover<CR>')
  buf_map(bufnr, 'n', '[a', ':LspDiagPrev<CR>')
  buf_map(bufnr, 'n', ']a', ':LspDiagNext<CR>')
  buf_map(bufnr, 'n', '<leader>e', ':LspDiagFloat<CR>')
  buf_map(bufnr, 'i', '<C-x><C-x>', ':LspSignatureHelp<CR>')
  buf_map(bufnr, 'n', 'ga', ':LspAct<CR>')
  buf_map(bufnr, 'x', 'ga', function()
    lsp.buf.code_action() -- range
  end)

  if client.supports_method('textDocument/formatting') then
    -- TODO: do we really want this? It's the base attach so maybe it's okay,
    -- but it also feels aggressive to disable all formatting in the base attach
    -- unless it's null_ls
    utils.enable_formatting(bufnr, function()
      lsp.buf.format({
        filter = function(_client)
          return _client.name == 'null-ls'
        end,
        bufnr = bufnr,
      })
    end)
  end

  require('illuminate').on_attach(client)
end

local capabilities = require('cmp_nvim_lsp').default_capabilities()

for _, server in ipairs({
  'bashls',
  'eslint',
  'gopls',
  'jsonls',
  'null_ls',
  'prismals',
  'pyright',
  'rust_analyzer',
  'sumneko_lua',
  'tsserver',
}) do
  require('jrnxf.lsp.' .. server).setup(on_attach, capabilities, utils)
end

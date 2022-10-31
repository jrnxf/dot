-- NOTES
-- for rust, make sure you have all rust-related tools installed
-- https://rustup.rs/
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

local eslint_disabled_buffers = {}

lsp.handlers['textDocument/signatureHelp'] = lsp.with(lsp.handlers.signature_help, border_opts)
lsp.handlers['textDocument/hover'] = lsp.with(lsp.handlers.hover, border_opts)

-- track buffers that eslint can't format to use prettier instead
lsp.handlers['textDocument/publishDiagnostics'] = function(_, result, ctx, config)
  local client = lsp.get_client_by_id(ctx.client_id)
  if not (client and client.name == 'eslint') then
    goto done
  end

  for _, diagnostic in ipairs(result.diagnostics) do
    if diagnostic.message:find('The file does not match your project config') then
      local bufnr = vim.uri_to_bufnr(result.uri)
      eslint_disabled_buffers[bufnr] = true
    end
  end

  ::done::
  return lsp.diagnostic.on_publish_diagnostics(nil, result, ctx, config)
end

local km = require('core.keymaps')

local augroup = vim.api.nvim_create_augroup('LspFormatting', {})

local lsp_formatting = function(bufnr)
  local clients = vim.lsp.get_active_clients({
    bufnr = bufnr,
  })
  lsp.buf.format({
    bufnr = bufnr,
    filter = function(client)
      -- if client.name == 'eslint' then
      --   return not eslint_disabled_buffers[bufnr]
      -- end

      if client.name == 'null-ls' then
        return true
        -- return not u.table.some(clients, function(_, other_client)
        --   return other_client.name == 'eslint' and not eslint_disabled_buffers[bufnr]
        -- end)
      end
    end,
  })
end

-- triggered when an lsp client attaches on a buffer
local on_attach = function(client, bufnr)
  -- commands
  u.buf_command(bufnr, 'LspHover', vim.lsp.buf.hover)
  u.buf_command(bufnr, 'LspDiagPrev', vim.diagnostic.goto_prev)
  u.buf_command(bufnr, 'LspDiagNext', vim.diagnostic.goto_next)
  u.buf_command(bufnr, 'LspDiagLine', vim.diagnostic.open_float)
  u.buf_command(bufnr, 'LspDiagQuickfix', vim.diagnostic.setqflist)
  u.buf_command(bufnr, 'LspSignatureHelp', vim.lsp.buf.signature_help)
  u.buf_command(bufnr, 'LspTypeDef', vim.lsp.buf.type_definition)
  u.buf_command(bufnr, 'LspRangeAct', vim.lsp.buf.range_code_action)
  u.buf_command(bufnr, 'LspRename', function()
    vim.lsp.buf.rename()
  end)

  u.buf_command(bufnr, 'LspRef', 'FzfLua lsp_references')
  u.buf_command(bufnr, 'LspSym', 'FzfLua lsp_workspace_symbols')
  u.buf_command(bufnr, 'LspAct', 'FzfLua lsp_code_actions')
  u.buf_command(bufnr, 'LspDef', function()
    require('fzf-lua').lsp_definitions({
      jump_to_single_result = true,
    })
  end)

  -- bindings
  u.buf_map(bufnr, 'n', 'gi', ':LspRename<CR>')
  u.buf_map(bufnr, 'n', 'K', ':LspHover<CR>')
  u.buf_map(bufnr, 'n', '[a', ':LspDiagPrev<CR>')
  u.buf_map(bufnr, 'n', ']a', ':LspDiagNext<CR>')
  u.buf_map(bufnr, 'n', '<leader>a', ':LspDiagLine<CR>')
  u.buf_map(bufnr, 'i', '<C-x><C-x>', '<cmd> LspSignatureHelp<CR>')

  u.buf_map(bufnr, 'n', 'gy', ':LspRef<CR>')
  u.buf_map(bufnr, 'n', 'gh', ':LspTypeDef<CR>')
  u.buf_map(bufnr, 'n', 'gd', ':LspDef<CR>')
  u.buf_map(bufnr, 'n', 'ga', ':LspAct<CR>')
  u.buf_map(bufnr, 'v', 'ga', '<Esc><cmd> LspRangeAct<CR>')

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
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

for _, server in ipairs({
  -- "bashls",
  -- "ccls",
  'eslint',
  -- "jsonls",
  'null_ls',
  -- "pyright",
  'sumneko_lua',
  'tsserver',
}) do
  require('lsp.' .. server).setup(on_attach, capabilities)
end

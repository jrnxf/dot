local u = require 'core.utils'

local ts_utils_settings = {
  -- imports
  import_all_scan_buffers = 100,
  update_imports_on_move = true,
  enable_import_on_completion = true,
  always_organize_imports = true,
  -- hints
  auto_inlay_hints = false,
}

local M = {}

M.getOpts = function(on_attach, capabilities)
  local lspconfig = require 'lspconfig'
  local ts_utils = require 'nvim-lsp-ts-utils'

  local opts = {
    root_dir = lspconfig.util.root_pattern 'package.json',
    -- commenting this out because I don't like the inlay hints
    on_attach = function(client, bufnr)
      on_attach(client, bufnr)

      -- we only want null_ls to format
      client.resolved_capabilities.document_formatting = false
      client.resolved_capabilities.document_range_formatting = false

      ts_utils.setup(ts_utils_settings)
      ts_utils.setup_client(client)

      u.buf_map(bufnr, 'n', 'gs', ':TSLspOrganize<CR>')
      u.buf_map(bufnr, 'n', 'gI', ':TSLspRenameFile<CR>')
      u.buf_map(bufnr, 'n', 'go', ':TSLspImportAll<CR>')
    end,
    flags = {
      debounce_text_changes = 150,
    },
    capabilities = capabilities,
  }

  return opts
end

return M

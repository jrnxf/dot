local buf_map = require('core.utils').keymap.buf_map

return function(client, bufnr)
  -- vim.notify(client.name .. " attached on buffer number " .. bufnr, vim.log.levels.DEBUG)

  if (client.name == "tsserver") then
    client.resolved_capabilities.document_formatting = false
    client.resolved_capabilities.document_range_formatting = false

    local ts_utils = require("nvim-lsp-ts-utils")

    ts_utils.setup({})
    ts_utils.setup_client(client)

    buf_map(bufnr, "n", "gs", ":TSLspOrganize<CR>")
    buf_map(bufnr, "n", "gi", ":TSLspRenameFile<CR>")
    buf_map(bufnr, "n", "go", ":TSLspImportAll<CR>")
  end

  vim.cmd("command! LspDeclaration lua vim.lsp.buf.declaration()")
  vim.cmd("command! LspDefinition lua vim.lsp.buf.definition()")
  vim.cmd("command! LspFormatting lua vim.lsp.buf.formatting()")
  vim.cmd("command! LspCodeAction lua vim.lsp.buf.code_action()")
  vim.cmd("command! LspHover lua vim.lsp.buf.hover()")
  vim.cmd("command! LspRename lua vim.lsp.buf.rename()")
  vim.cmd("command! LspReferences lua vim.lsp.buf.references()")
  vim.cmd("command! LspTypeDefinition lua vim.lsp.buf.type_definition()")
  vim.cmd("command! LspImplementation lua vim.lsp.buf.implementation()")
  vim.cmd("command! LspSignatureHelp lua vim.lsp.buf.signature_help()")
  vim.cmd("command! LspDiagQuickfix lua vim.diagnostic.setqflist()")
  vim.cmd("command! LspDiagPrev lua vim.diagnostic.goto_prev()")
  vim.cmd("command! LspDiagNext lua vim.diagnostic.goto_next()")
  vim.cmd("command! LspDiagLine lua vim.diagnostic.open_float()")

  buf_map(bufnr, "n", "gD",             ":LspDeclaration<CR>")
  buf_map(bufnr, "n", "gd",             ":LspDefinition<CR>")
  buf_map(bufnr, "n", "gt",             ":LspTypeDefinition<CR>")
  buf_map(bufnr, "n", "gr",             ":LspReferences<CR>")
  buf_map(bufnr, "n", "gi",             ":LspImplementation<CR>")
  buf_map(bufnr, "n", "ga",             ":LspCodeAction<CR>")
  buf_map(bufnr, "n", "K",              ":LspHover<CR>")
  buf_map(bufnr, "i", "<C-k>",          ":LspSignatureHelp<CR>")
  buf_map(bufnr, "n", "<Leader>rn",     ":LspRename<CR>")
  buf_map(bufnr, "n", "<Leader>a",      ":LspDiagLine<CR>")
  buf_map(bufnr, "n", "<Leader>q",      ":LspDiagQuickfix<CR>")
  buf_map(bufnr, "n", "[a",             ":LspDiagPrev<CR>")
  buf_map(bufnr, "n", "]a",             ":LspDiagNext<CR>")

  if client.resolved_capabilities.document_formatting then
      vim.cmd("autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()")
  end
end

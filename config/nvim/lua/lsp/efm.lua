local M = {}

M.getOpts = function(on_attach, capabilities)
  local opts = {
    on_attach = function(client, bufnr)
      on_attach(client, bufnr)
      client.resolved_capabilities.document_formatting = true
    end,
    capabilities = capabilities,
    init_options = { documentFormatting = true },
    settings = {
      languages = {
        python = {
          -- ensure black is installed via homebrew
          { formatCommand = 'black --quiet -', formatStdin = true },
        },
      },
    },

    -- from the docs: In order for neovim's built-in language server
    -- client to send the appropriate languageId to EFM, you must
    -- specify filetypes in your call to setup{}. Otherwise lspconfig
    -- will launch EFM on the BufEnter instead of the FileType autocommand,
    -- and the filetype variable used to populate the languageId will not
    -- yet be set.
    filetypes = { 'python' },
  }
  return opts
end

return M

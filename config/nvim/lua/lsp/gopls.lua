local M = {}

M.getOpts = function(on_attach, capabilities)
  local opts = {
    on_attach = function(client, bufnr)
      on_attach(client, bufnr)
      vim.cmd 'au BufWritePre <buffer> lua require"go.format".gofmt()'
    end,
    capabilities = capabilities,
  }
  return opts
end

return M

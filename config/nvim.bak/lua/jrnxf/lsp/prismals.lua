local M = {}

M.setup = function()
  require('lspconfig').prismals.setup({
    -- must pass at least an empty table otherwise throws errors
  })
end

return M

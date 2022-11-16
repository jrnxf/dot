local km = require('core.keymaps')
local trouble = require('trouble')

trouble.setup({
  -- auto_open = true, -- this is nice sometimes
  auto_close = true,
})

km.nnoremap('<leader>xx', '<cmd>TroubleToggle<CR>')
km.nnoremap('<leader>xw', '<cmd>TroubleToggle workspace_diagnostics<CR>')
km.nnoremap('<leader>xd', '<cmd>TroubleToggle document_diagnostics<CR>')
km.nnoremap('<leader>xq', '<cmd>TroubleToggle quickfix<CR>')
km.nnoremap('<leader>xl', '<cmd>TroubleToggle loclist<CR>')
km.nnoremap('gR', '<cmd>TroubleToggle lsp_references<CR>')
km.nnoremap('<C-j>', function()
  trouble.next({ skip_groups = true, jump = true })
end)
km.nnoremap('<C-k>', function()
  trouble.previous({ skip_groups = true, jump = true })
end)
km.nnoremap('gd', '<cmd>Trouble lsp_definitions<CR>')
km.nnoremap('gD', '<cmd>Trouble lsp_type_definitions<CR>')
km.nnoremap('gr', '<cmd>Trouble lsp_references<CR>')
km.nnoremap('gi', '<cmd>Trouble lsp_implementations<CR>')

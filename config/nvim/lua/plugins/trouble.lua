local u = require('core.utils')

require('trouble').setup({
  -- your configuration comes here
  -- or leave it empty to use the default settings
  -- refer to the configuration section below
})

u.map('n', '<leader>xx', '<cmd>TroubleToggle<CR>', { silent = true, noremap = true })
u.map('n', '<leader>xw', '<cmd>Trouble workspace_diagnostics<CR>', { silent = true, noremap = true })
u.map('n', '<leader>xd', '<cmd>Trouble document_diagnostics<CR>', { silent = true, noremap = true })
u.map('n', '<leader>xq', '<cmd>Trouble quickfix<CR>', { silent = true, noremap = true })
u.map('n', '<leader>xl', '<cmd>Trouble loclist<CR>', { silent = true, noremap = true })
u.map('n', '<C-j>', ':lua require("trouble").next({skip_groups = true, jump = true})<CR>')
u.map('n', '<C-k>', ':lua require("trouble").previous({skip_groups = true, jump = true})<CR>')

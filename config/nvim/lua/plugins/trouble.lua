local u = require 'core.utils'

require('trouble').setup {
  -- your configuration comes here
  -- or leave it empty to use the default settings
  -- refer to the configuration section below
}

-- Trouble
u.map('n', '<leader>xw', '<cmd>Trouble workspace_diagnostics<cr>', { silent = true, noremap = true })
u.map('n', '<leader>xx', '<cmd>Trouble<cr>', { silent = true, noremap = true })
u.map('n', '<leader>xd', '<cmd>Trouble document_diagnostics<cr>', { silent = true, noremap = true })
u.map('n', '<leader>xl', '<cmd>Trouble loclist<cr>', { silent = true, noremap = true })
u.map('n', '<leader>xq', '<cmd>Trouble quickfix<cr>', { silent = true, noremap = true })
u.map('n', '<C-j>', ':lua require("trouble").next({skip_groups = true, jump = true})<CR>')
u.map('n', '<C-k>', ':lua require("trouble").previous({skip_groups = true, jump = true})<CR>')

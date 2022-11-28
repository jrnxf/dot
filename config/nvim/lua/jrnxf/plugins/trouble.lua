local trouble = require('trouble')

trouble.setup({
  -- auto_open = true, -- this is nice sometimes
  auto_close = true,
  auto_jump = { 'lsp_definitions', 'lsp_type_definitions', 'lsp_references', 'lsp_implementations' }, -- for the given modes, automatically jump if there is only a single result
  sort_keys = {
    -- 'severity', -- I prefer to have my errors displayed top to bottom in the file vs by severity
    'filename',
    'lnum',
    'col',
  },
})

nmap('<leader>xx', '<cmd>TroubleToggle<CR>')
nmap('<leader>xw', '<cmd>TroubleToggle workspace_diagnostics<CR>')
nmap('<leader>xd', '<cmd>TroubleToggle document_diagnostics<CR>')
nmap('<leader>xq', '<cmd>TroubleToggle quickfix<CR>')
nmap('<leader>xl', '<cmd>TroubleToggle loclist<CR>')
nmap('gR', '<cmd>TroubleToggle lsp_references<CR>')
nmap('<C-j>', function()
  if trouble.is_open() then
    trouble.next({ skip_groups = true, jump = true })
  end
end)
nmap('<C-k>', function()
  if trouble.is_open() then
    trouble.previous({ skip_groups = true, jump = true })
  end
end)
nmap('gd', '<cmd>Trouble lsp_definitions<CR>')
nmap('gD', '<cmd>Trouble lsp_type_definitions<CR>')
nmap('gr', '<cmd>Trouble lsp_references<CR>')
nmap('gi', '<cmd>Trouble lsp_implementations<CR>')

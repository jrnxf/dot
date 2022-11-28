local opts = { silent = true }

local ui = require('harpoon.ui')

nmap('<leader>m', require('harpoon.mark').add_file, opts)
nmap('<leader>hh', ui.toggle_quick_menu, opts)

nmap('<leader>1', function() ui.nav_file(1) end, opts)
nmap('<leader>2', function() ui.nav_file(2) end, opts)
nmap('<leader>3', function() ui.nav_file(3) end, opts)
nmap('<leader>4', function() ui.nav_file(4) end, opts)

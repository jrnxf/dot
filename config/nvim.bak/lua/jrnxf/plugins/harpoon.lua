local ui = require('harpoon.ui')

nmap('<leader>m', require('harpoon.mark').add_file)
nmap('<leader>h', ui.toggle_quick_menu)

nmap('<leader>j', function()
  ui.nav_file(1)
end)

nmap('<leader>k', function()
  ui.nav_file(2)
end)

nmap('<leader>l', function()
  ui.nav_file(3)
end)

nmap('<leader>;', function()
  ui.nav_file(4)
end)

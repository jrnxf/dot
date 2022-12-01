local illuminate = require('illuminate')

nmap('<A-j>', function()
  illuminate.next_reference({ wrap = true })
end)
nmap('<A-k>', function()
  illuminate.next_reference({ reverse = true, wrap = true })
end)

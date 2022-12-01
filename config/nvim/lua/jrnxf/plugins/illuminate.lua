local illuminate = require('illuminate')

nmap('<A-n>', function()
  illuminate.next_reference({ wrap = true })
end)
nmap('<A-p>', function()
  illuminate.next_reference({ reverse = true, wrap = true })
end)

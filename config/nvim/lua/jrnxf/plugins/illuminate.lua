local illuminate = require('illuminate')

illuminate.configure({
  filetypes_denylist = {
    'dirvish',
    'fugitive',
    'packer',
    'NvimTree',
    'TelescopePrompt',
  },
})
nmap('<A-n>', function()
  illuminate.next_reference({ wrap = true })
end)
nmap('<A-p>', function()
  illuminate.next_reference({ reverse = true, wrap = true })
end)

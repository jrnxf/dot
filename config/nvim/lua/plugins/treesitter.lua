return function()
  local treesitter = require 'nvim-treesitter.configs'

  treesitter.setup {
    -- maintained is any parser with maintainers
    ensure_installed = 'all',
    ignore_install = { 'phpdoc' }, -- List of parsers to ignore installing
    highlight = { enable = true },
    -- plugins
    autopairs = { enable = true },
    context_commentstring = {
      enable = true,
      enable_autocmd = false,
    },
    autotag = { enable = true },
  }
end

return function()
  local treesitter = require 'nvim-treesitter.configs'

  treesitter.setup {
    -- maintained is any parser with maintainers
    ensure_installed = 'maintained',
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

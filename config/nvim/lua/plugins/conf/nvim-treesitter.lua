return function()
  local nvim_treesitter_configs = require 'nvim-treesitter.configs'

  nvim_treesitter_configs.setup {
    -- maintained is any parser with maintainers
    ensure_installed = "maintained",
    highlight = { enable = true },
    -- see https://github.com/windwp/nvim-ts-autotag
    autotag = { enable = true },
  }
end

return function()
  local ok, nvim_treesitter_configs = safe_require 'nvim-treesitter.configs'
  if not ok then
    return
  end

  nvim_treesitter_configs.setup {
    -- maintained is any parser with maintainers
    ensure_installed = "maintained",
    highlight = { enable = true },
    -- see https://github.com/windwp/nvim-ts-autotag
    autotag = { enable = true },
  }
end

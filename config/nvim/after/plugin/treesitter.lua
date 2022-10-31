require('nvim-treesitter.configs').setup({
  ensure_installed = {
    'bash',
    'css',
    'javascript',
    'json',
    'jsonc',
    'lua',
    'markdown',
    'scss',
    'tsx',
    'typescript',
    'yaml',
  },
  highlight = {
    enable = true,
    disable = function(_, bufnr)
      return vim.api.nvim_buf_line_count(bufnr) > 5000
    end,
  },
  -- plugins
  autopairs = { enable = true },
  context_commentstring = {
    enable = true,
    enable_autocmd = false,
  },
  autotag = { enable = true },
})

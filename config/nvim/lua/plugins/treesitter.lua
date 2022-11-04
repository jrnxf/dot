require('nvim-treesitter.configs').setup({
  ensure_installed = {
    'bash',
    'css',
    'html',
    'javascript',
    'json',
    'jsonc',
    'lua',
    'markdown',
    'markdown_inline',
    'scss',
    'toml',
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
  indent = {
    enable = true,
    disable = function(_, bufnr)
      return vim.api.nvim_buf_line_count(bufnr) > 5000
    end,
  },
  -- plugins
  context_commentstring = {
    enable = true,
    enable_autocmd = false,
  },
  autopairs = { enable = true },
  autotag = { enable = true },
})

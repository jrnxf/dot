require("nvim-treesitter.configs").setup({
  ensure_installed = {
    'bash',
    'c',
    'cpp',
    'css',
    'javascript',
    'json',
    'jsonc',
    'lua',
    'make',
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
  -- plugins
  autopairs = { enable = true },
  context_commentstring = {
    enable = true,
    enable_autocmd = false,
  },
  autotag = { enable = true },
})

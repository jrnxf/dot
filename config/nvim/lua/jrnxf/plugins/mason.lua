require('mason').setup({
  ui = { border = 'rounded' },
})

require('mason-tool-installer').setup({
  -- a list of all tools you want to ensure are installed upon
  -- start; they should be the names Mason uses for each tool
  ensure_installed = {
    'tailwindcss-language-server',
    'pyright',
    'html-lsp',
    'bash-language-server',
    'editorconfig-checker',
    'gopls',
    'lua-language-server',
    'luacheck',
    'misspell',
    'prettierd',
    'shellcheck',
    'shfmt',
    'stylua',
    'typescript-language-server',
  },
  -- automatically install / update on startup. If set to false nothing
  -- will happen on startup. You can use :MasonToolsInstall or
  -- :MasonToolsUpdate to install tools and check for updates.
  -- Default: true
  run_on_start = true,
})

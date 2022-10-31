vim.cmd('packadd packer.nvim')

return require('packer').startup(function(use)
  use({ 'wbthomason/packer.nvim', opt = true })

  local config = function(name)
    return string.format("require('plugins.%s')", name)
  end

  use('tpope/vim-surround')
  use('tpope/vim-commentary')
  use('tpope/vim-fugitive')
  use('moll/vim-bbye')

  use({
    'folke/trouble.nvim',
    requires = 'kyazdani42/nvim-web-devicons',
    config = config('trouble'),
  })

  use({
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate',
    config = config('treesitter'),
  })

  use({ -- automatically close jsx tags
    'windwp/nvim-ts-autotag',
    ft = { 'typescript' },
  })

  use({ -- makes jsx comments actually work
    'JoosepAlviste/nvim-ts-context-commentstring',
    ft = { 'typescript' },
  })

  use({
    'karb94/neoscroll.nvim',
    config = config('neoscroll'),
  })

  use({
    'ggandor/leap.nvim',
    config = config('leap'),
  })

  use({
    'max397574/better-escape.nvim',
    config = function()
      require('better_escape').setup({
        mapping = { 'jk', 'kj' },
      })
    end,
  })

  use({
    'rmehri01/onenord.nvim',
    config = function()
      -- to inspect colors run: lua print(vim.inspect(require'onenord.colors'.load()))
      local colors = {
        bg = '#191c23',
        active_line = '#262C37',
      }

      require('onenord').setup({
        custom_highlights = {
          CursorLine = {
            bg = colors.active_line,
          },
        },
        custom_colors = {
          bg = colors.bg,
          active = colors.bg,
          float = colors.active_line,
        },
      })
    end,
  })

  use({
    'kyazdani42/nvim-tree.lua',
    requires = 'kyazdani42/nvim-web-devicons',
    config = config('tree'),
  })

  use({
    'akinsho/nvim-bufferline.lua',
    config = config('bufferline'),
  })

  use({
    'nvim-lualine/lualine.nvim',
    config = config('lualine'),
  })

  use({
    'lewis6991/gitsigns.nvim',
    config = function()
      require('gitsigns').setup({})
    end,
  })

  use({
    'hrsh7th/nvim-cmp', -- autocomplete plugin
    requires = {
      'hrsh7th/cmp-nvim-lsp', -- neovim's built-in language server client
      'hrsh7th/cmp-buffer', -- buffer words
      'hrsh7th/cmp-path', -- filesystem paths
      'hrsh7th/cmp-cmdline', -- vim's cmdline
      'hrsh7th/cmp-emoji', -- emojis
      'onsails/lspkind-nvim', -- icons pictograms
    },
    config = config('cmp'),
  })
  use({
    'windwp/nvim-autopairs', -- autocomplete pairs
    config = function()
      require('nvim-autopairs').setup({
        check_ts = true,
      })
    end,
  })
  use({
    'nvim-telescope/telescope.nvim',
    requires = { 'nvim-lua/plenary.nvim', 'nvim-telescope/telescope-fzy-native.nvim' },
    config = config('telescope'),
  })

  use({
    'ray-x/go.nvim',
    ft = { 'go' },
    config = function()
      require('go').setup({})
    end,
  })

  use({
    'williamboman/mason.nvim',
    requires = {
      'jose-elias-alvarez/null-ls.nvim',
      'neovim/nvim-lspconfig',
      'williamboman/mason-lspconfig.nvim',
    },
    config = function()
      require('mason').setup({
        ui = {
          border = 'rounded',
        },
      })
    end,
  })

  use({
    'jose-elias-alvarez/null-ls.nvim',
    requires = 'nvim-lua/plenary.nvim',
  })

  use('jose-elias-alvarez/typescript.nvim')
end)

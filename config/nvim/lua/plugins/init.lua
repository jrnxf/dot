local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({ 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path })
    vim.cmd([[packadd packer.nvim]])
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

return require('packer').startup(function(use)
  use('wbthomason/packer.nvim')

  use('tpope/vim-surround')
  use('tpope/vim-commentary')
  use('tpope/vim-fugitive')
  use('moll/vim-bbye')

  use({
    'folke/trouble.nvim',
    requires = 'kyazdani42/nvim-web-devicons',
  })

  use({
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate',
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
  })

  use({
    'ggandor/leap.nvim',
  })

  use({
    'max397574/better-escape.nvim',
    config = function()
      require('better_escape').setup({
        mapping = { 'jk', 'kj' },
      })
    end,
  })

  -- colorschemes
  use('rmehri01/onenord.nvim')
  use('navarasu/onedark.nvim')
  use({ 'rose-pine/neovim', as = 'rose-pine' })
  use('catppuccin/nvim')

  use({
    'kyazdani42/nvim-tree.lua',
    requires = 'kyazdani42/nvim-web-devicons',
  })

  use({
    'akinsho/nvim-bufferline.lua',
  })

  use({
    'nvim-lualine/lualine.nvim',
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

  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if packer_bootstrap then
    require('packer').sync()
  end
end)

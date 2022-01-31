vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
  use { 'wbthomason/packer.nvim', opt = true }

  local conf = function(name)
    return require('plugins.conf.' .. name)
  end

  use 'tpope/vim-surround'
  use 'tpope/vim-commentary'
  use 'tpope/vim-fugitive'

  use 'moll/vim-bbye'

  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate',
    config = function()
      require('nvim-treesitter.configs').setup {
        -- maintained is any parser with maintainers
        ensure_installed = 'maintained',
        highlight = { enable = true },
      }
    end,
  }
  use 'nvim-treesitter/playground'

  use {
    'rmehri01/onenord.nvim',
    config = function()
      require('onenord').setup {}
    end,
  }

  use {
    'kyazdani42/nvim-tree.lua',
    requires = {
      'kyazdani42/nvim-web-devicons',
    },
    config = conf 'nvim-tree',
  }

  use {
    'akinsho/nvim-bufferline.lua',
    config = conf 'nvim-bufferline',
  }

  use {
    'nvim-lualine/lualine.nvim',
    config = function()
      require('lualine').setup {
        options = {
          theme = 'nord',
        },
      }
    end,
  }

  use {
    'lewis6991/gitsigns.nvim',
    requires = {
      'nvim-lua/plenary.nvim',
    },
    config = function()
      require('gitsigns').setup {}
    end,
  }

  use {
    'hrsh7th/nvim-cmp', -- autocomplete plugin
    -- TODO verify the need for each of these
    requires = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-cmdline',
      'hrsh7th/cmp-emoji',
      'onsails/lspkind-nvim', -- Enables icons on completions
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
    },
    config = conf 'nvim-cmp',
  }

  use {
    'windwp/nvim-autopairs', -- autocomplete pairs
    wants = 'nvim-cmp',
    config = function()
      require('nvim-autopairs').setup {}
    end,
  }

  use {
    'nvim-telescope/telescope.nvim',
    requires = { { 'nvim-lua/plenary.nvim' } },
    config = conf 'telescope',
  }

  use 'williamboman/nvim-lsp-installer'

  use {
    'neovim/nvim-lspconfig',
    requires = {
      'williamboman/nvim-lsp-installer',
      'jose-elias-alvarez/nvim-lsp-ts-utils',
      'jose-elias-alvarez/null-ls.nvim',
    },
  }

  use 'folke/lua-dev.nvim'
end)

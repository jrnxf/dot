vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
  use { 'wbthomason/packer.nvim', opt = true }

  local conf = function(name)
    return require('plugins.' .. name)
  end

  use 'tpope/vim-surround'
  use 'tpope/vim-commentary'
  use 'tpope/vim-fugitive'
  use 'moll/vim-bbye' -- easy buffer closing

  use {
    'folke/trouble.nvim',
    requires = 'kyazdani42/nvim-web-devicons',
    config = function()
      require('trouble').setup {
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
      }
    end,
  }

  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate',
    requires = {
      'nvim-treesitter/playground',
      'windwp/nvim-ts-autotag',
    },
    config = function()
      require('nvim-treesitter.configs').setup {
        ensure_installed = 'maintained', -- install any parser with maintainer
        highlight = { enable = true },
      }
    end,
  }

  use {
    'karb94/neoscroll.nvim',
    config = function()
      require('neoscroll').setup {}
    end,
  }

  use {
    'rmehri01/onenord.nvim',
    config = function()
      require('onenord').setup {}
    end,
  }

  -- use {
  --   'rebelot/kanagawa.nvim',
  --   config = function()
  --     vim.cmd [[colorscheme kanagawa]]
  --   end,
  -- }

  -- use {
  --   'navarasu/onedark.nvim',
  --   config = function()
  --     require('onedark').setup {
  --       style = 'cool',
  --     }
  --     require('onedark').load()
  --   end,
  -- }

  -- -- make sure to fix padding on nvim-tree with this theme
  -- use {
  --   'catppuccin/nvim',
  --   as = 'catppuccin',
  --   config = function()
  --     vim.cmd [[colorscheme catppuccin]]
  --   end,
  -- }

  use {
    'kyazdani42/nvim-tree.lua',
    requires = {
      'kyazdani42/nvim-web-devicons',
    },
    config = conf 'tree',
  }

  use {
    'akinsho/nvim-bufferline.lua',
    config = conf 'bufferline',
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
    config = conf 'cmp',
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
    requires = { 'nvim-lua/plenary.nvim', 'nvim-lua/popup.nvim', 'nvim-telescope/telescope-fzy-native.nvim' },
    config = conf 'telescope',
  }

  use 'williamboman/nvim-lsp-installer'

  use {
    'ray-x/go.nvim',
    config = function()
      require('go').setup {}
    end,
  }

  use {
    'neovim/nvim-lspconfig',
    requires = {
      'williamboman/nvim-lsp-installer',
      'jose-elias-alvarez/nvim-lsp-ts-utils',
      'jose-elias-alvarez/null-ls.nvim',
      'folke/lua-dev.nvim',
    },
  }
end)

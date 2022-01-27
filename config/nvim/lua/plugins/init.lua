vim.cmd("packadd packer.nvim")
return require("packer").startup(function()
    use({ "wbthomason/packer.nvim", opt = true })

    local function conf(name)
        return require(string.format('plugins.conf.%s', name))
    end

    -- basic
    use {
      "tpope/vim-surround",
    }
    use "tpope/vim-commentary"
    use "tpope/vim-fugitive"

    -- treesitter
    use {
        "nvim-treesitter/nvim-treesitter",
        run = ":TSUpdate",
        config = conf 'nvim-treesitter'
    }
    use "nvim-treesitter/playground"
    use("windwp/nvim-ts-autotag") -- automatically close jsx tags

    use {
      'neovim/nvim-lspconfig',
      config = require 'lsp', -- this reference local module
      requires = {
        'williamboman/nvim-lsp-installer',
        'jose-elias-alvarez/nvim-lsp-ts-utils',
        'jose-elias-alvarez/null-ls.nvim',
      },
    }

    -- appearance
    use {
      'rmehri01/onenord.nvim',
      config = function()
        require'onenord'.setup {}
      end
    }
    -- use {
    --   'navarasu/onedark.nvim',
    --   config = function()
    --     local onedark = require'onedark'
    --     onedark.setup {
    --       style = 'darker'
    --     }
    --     onedark.load()
    --   end
    -- }
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
      config = conf 'lualine',
    }
    use {
      'lewis6991/gitsigns.nvim',
      requires = {
        'nvim-lua/plenary.nvim'
      },
      config = function()
        require('gitsigns').setup {}
      end
    }

    -- Autocompletion plugin
    use {
      'hrsh7th/nvim-cmp',
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
        require'nvim-autopairs'.setup {}
      end
    }

    -- search
    use {
        'nvim-telescope/telescope.nvim',
        requires = { {'nvim-lua/plenary.nvim'} },
        config = conf 'telescope'
      }
end)

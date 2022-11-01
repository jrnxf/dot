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

local config = function(name)
  return string.format("require('plugins.%s')", name)
end

return require('packer').startup({
  function(use)
    use('wbthomason/packer.nvim')

    use('lewis6991/impatient.nvim')

    use('tpope/vim-surround')
    use('tpope/vim-commentary')
    use('tpope/vim-fugitive')
    use('moll/vim-bbye')

    use('stevearc/dressing.nvim') -- breaks in nvim-tree floating mode
    use({
      'vigoux/notifier.nvim',
      config = function()
        require('notifier').setup({
          notify = {
            clear_time = 3000,
          },
        })
      end,
    })
    use({
      'folke/todo-comments.nvim',
      requires = 'nvim-lua/plenary.nvim',
      config = function()
        require('todo-comments').setup({})
      end,
    })

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

    -- colorschemes
    use('rmehri01/onenord.nvim')
    use('navarasu/onedark.nvim')
    use({ 'rose-pine/neovim', as = 'rose-pine' })
    use('catppuccin/nvim')

    use({
      'kyazdani42/nvim-tree.lua',
      requires = 'kyazdani42/nvim-web-devicons',
      config = config('nvim-tree'),
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
      'hrsh7th/nvim-cmp', -- base completion engine
      requires = {
        'hrsh7th/cmp-nvim-lsp', -- neovim's built-in language server client
        'hrsh7th/cmp-buffer', -- buffer words
        'hrsh7th/cmp-path', -- filesystem paths
        'hrsh7th/cmp-cmdline', -- vim's cmdline
        'hrsh7th/cmp-emoji', -- emojis
        'onsails/lspkind-nvim', -- icons pictograms
        'L3MON4D3/LuaSnip', -- nvim-cmp needs at least one snippet source
        'saadparwaiz1/cmp_luasnip', -- luasnips,
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

    -- TODO: Automatically set up your configuration after cloning packer.nvim
    -- Put this at the end after all plugins
    if packer_bootstrap then
      require('packer').sync()
    end
  end,
  config = {
    display = {
      open_fn = function()
        return require('packer.util').float({ border = 'rounded' })
      end,
    },
  },
})

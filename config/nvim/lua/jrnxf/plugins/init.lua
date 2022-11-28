local ensure_packer = function()
  local install_path = vim.fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
  local packer_found = vim.fn.empty(vim.fn.glob(install_path)) == 0
  if packer_found then
    return false
  else
    vim.fn.system({ 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path })
    vim.cmd([[packadd packer.nvim]])
    return true
  end
end
local packer_bootstrap = ensure_packer()

local config = function(name)
  return string.format("require('jrnxf.plugins.%s')", name)
end

return require('packer').startup({
  function(use)
    use('wbthomason/packer.nvim')

    use('lewis6991/impatient.nvim')

    use('tpope/vim-surround')

    use('tpope/vim-commentary')

    use('tpope/vim-fugitive')

    use('stevearc/dressing.nvim')

    use('rcarriga/nvim-notify')

    use('folke/zen-mode.nvim')

    use({
      'nvim-treesitter/nvim-treesitter',
      requires = {
        'nvim-treesitter/playground', -- not required, but I like
      },
      run = function()
        local ts_update = require('nvim-treesitter.install').update({ with_sync = true })
        ts_update()
      end,
      config = config('treesitter'),
    })

    -- automatically close jsx tags
    use({ 'windwp/nvim-ts-autotag', ft = { 'typescript' } })

    -- makes jsx comments actually work
    use({ 'JoosepAlviste/nvim-ts-context-commentstring', ft = { 'typescript' } })

    use({ 'karb94/neoscroll.nvim', config = config('neoscroll') })

    use({ 'ggandor/leap.nvim', config = config('leap') })

    use({
      'max397574/better-escape.nvim',
      config = function()
        require('better_escape').setup({
          mapping = { 'jk', 'kj' },
        })
      end,
    })

    use({
      'EdenEast/nightfox.nvim',
      config = config('nightfox'),
    })

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
      'feline-nvim/feline.nvim',
      event = 'VimEnter',
      config = config('feline.init'),
      requires = { 'kyazdani42/nvim-web-devicons' },
    })

    -- -- currently breaks the nvim splash screen currently 🙁
    -- -- use({
    -- --   'folke/todo-comments.nvim',
    -- --   requires = 'nvim-lua/plenary.nvim',
    -- --   config = function()
    -- --     require('todo-comments').setup({})
    -- --   end,
    -- -- })

    use({
      'lewis6991/gitsigns.nvim',
      config = function()
        require('gitsigns').setup({})
      end,
    })

    use('rafamadriz/friendly-snippets')

    use({
      'windwp/nvim-autopairs',
      config = function()
        require('nvim-autopairs').setup({
          disable_filetype = {
            'TelescopePrompt',
            'vim',
          },
          check_ts = true,
        })
      end,
    })

    use({
      'hrsh7th/nvim-cmp',
      requires = {
        'hrsh7th/cmp-nvim-lua',
        'hrsh7th/cmp-nvim-lsp',
        'hrsh7th/cmp-buffer',
        'hrsh7th/cmp-path',
        'hrsh7th/cmp-cmdline',
        'onsails/lspkind-nvim',
      },
      config = config('cmp'),
    })

    use({
      'L3MON4D3/LuaSnip',
      after = 'nvim-cmp',
      requires = {
        'saadparwaiz1/cmp_luasnip',
      },
      config = config('luasnip'),
    })

    use({ 'ThePrimeagen/harpoon', config = config('harpoon') })

    use({ 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' })

    use({
      'nvim-telescope/telescope.nvim',
      requires = {
        'nvim-lua/plenary.nvim', -- sssential library
        'kyazdani42/nvim-web-devicons', -- file icons
        'xiyaowong/telescope-emoji.nvim', -- emoji picker
        'nvim-telescope/telescope-live-grep-args.nvim',
        { 'dhruvmanila/telescope-bookmarks.nvim', tag = '*' },
      },
      config = config('telescope'),
    })

    use({
      'ray-x/go.nvim',
      ft = { 'go' },
      config = function()
        require('go').setup()
      end,
    })
    use({
      'vigoux/notifier.nvim',
      config = function()
        require('notifier').setup({
          notify = {
            clear_time = 5000,
            min_level = vim.log.levels.INFO,
          },
        })
      end,
    })
    use({
      'j-hui/fidget.nvim',
      config = function()
        require('fidget').setup()
      end,
    })

    use({
      'williamboman/mason.nvim',
      requires = {
        'jose-elias-alvarez/null-ls.nvim',
        'neovim/nvim-lspconfig',
        'williamboman/mason-lspconfig.nvim',
        'WhoIsSethDaniel/mason-tool-installer.nvim',
      },
      config = config('mason'),
    })

    use({
      'neovim/nvim-lspconfig',
      requires = {
        'jose-elias-alvarez/null-ls.nvim',
        'hrsh7th/nvim-cmp',
      },
      config = config('lsp'),
    })

    use({ 'jose-elias-alvarez/null-ls.nvim', requires = 'nvim-lua/plenary.nvim' })

    use('jose-elias-alvarez/typescript.nvim')

    use({ 'numtostr/BufOnly.nvim', cmd = 'BufOnly' })

    use({
      -- '~/Dev/trouble.nvim',
      'thatvegandev/trouble.nvim',
      -- 'folke/trouble.nvim',
      requires = 'kyazdani42/nvim-web-devicons',
      config = config('trouble'),
    })

    -- use({
    --   'folke/noice.nvim',
    --   config = function()
    --     require('noice').setup({
    --       lsp = {
    --         -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
    --         override = {
    --           ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
    --           ['vim.lsp.util.stylize_markdown'] = true,
    --           ['cmp.entry.get_documentation'] = true,
    --         },
    --       },
    --       -- you can enable a preset for easier configuration
    --       presets = {
    --         bottom_search = true, -- use a classic bottom cmdline for search
    --         command_palette = true, -- position the cmdline and popupmenu together
    --         long_message_to_split = true, -- long messages will be sent to a split
    --         inc_rename = false, -- enables an input dialog for inc-rename.nvim (which I don't use)
    --         lsp_doc_border = true, -- add a border to hover docs and signature help
    --       },
    --     })
    --   end,
    --   requires = {
    --     -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
    --     'MunifTanjim/nui.nvim',
    --     -- OPTIONAL:
    --     --   `nvim-notify` is only needed, if you want to use the notification view.
    --     --   If not available, we use `mini` as the fallback
    --     'rcarriga/nvim-notify',
    --   },
    -- })

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

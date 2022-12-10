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

local packer_handlers = {
  conf = function(_, plugin, value)
    plugin.config = ([[require('jrnxf.plugins.%s')]]):format(value)
  end,
}

local packer = require('packer')

packer.init({
  display = {
    open_fn = function()
      return require('packer.util').float({ border = 'rounded' })
    end,
  },
})

packer.set_handler('conf', packer_handlers.conf)

local plugins = {
  { 'wbthomason/packer.nvim' },
  { 'lewis6991/impatient.nvim' },
  { 'nvim-lua/plenary.nvim' },
  { 'tpope/vim-surround' },
  { 'tpope/vim-commentary' },
  { 'tpope/vim-fugitive' },
  {
    'smjonas/inc-rename.nvim',
    config = function()
      require('inc_rename').setup({ preview_empty_name = true })
    end,
  },
  { 'stevearc/dressing.nvim', after = 'telescope', conf = 'dressing' },
  { 'MunifTanjim/nui.nvim', conf = 'nui' },
  { 'folke/zen-mode.nvim' },
  {
    'nvim-treesitter/nvim-treesitter',
    run = function()
      local ts_update = require('nvim-treesitter.install').update({ with_sync = true })
      ts_update()
    end,
    conf = 'treesitter',
  },
  { 'nvim-treesitter/playground' },
  { 'windwp/nvim-ts-autotag', ft = { 'typescript' } }, -- automatically close jsx tags
  { 'JoosepAlviste/nvim-ts-context-commentstring', ft = { 'typescript' } }, -- makes jsx comments actually work
  -- { 'karb94/neoscroll.nvim', conf = 'neoscroll' },
  { 'declancm/cinnamon.nvim', conf = 'cinnamon' },
  -- { 'mrjones2014/legendary.nvim', conf = 'legendary' },
  -- { 'ggandor/leap.nvim', conf = 'leap' },
  {
    'max397574/better-escape.nvim',
    config = function()
      require('better_escape').setup({ mapping = { 'jk', 'kj' } })
    end,
  },
  { 'EdenEast/nightfox.nvim', conf = 'nightfox' },
  { 'rose-pine/neovim', as = 'rose-pine' },
  { 'rmehri01/onenord.nvim' },
  { 'navarasu/onedark.nvim' },
  { 'catppuccin/nvim' },
  {
    'nvim-tree/nvim-tree.lua',
    requires = 'nvim-tree/nvim-web-devicons',
    conf = 'nvim-tree',
  },
  {
    'feline-nvim/feline.nvim',
    -- DANGER
    -- event = 'VimEnter', -- TODO: create ticket with packer to figure out why adding this actually makes VimEnter fire twice!
    -- END DANGER
    -- after = 'noice',
    requires = { 'kyazdani42/nvim-web-devicons' },
    conf = 'feline.init',
  },
  -- currently breaks the nvim splash screen currently 🙁
  -- {
  --   'folke/todo-comments.nvim',
  --   requires = 'nvim-lua/plenary.nvim',
  --   config = function()
  --     require('todo-comments').setup({})
  --   end,
  -- }
  {
    'lewis6991/gitsigns.nvim',
    config = function()
      require('gitsigns').setup()
    end,
  },
  -- {'rafamadriz/friendly-snippets'},
  ---- Completion --------------------------------------------------
  {
    'windwp/nvim-autopairs',
    as = 'autopairs',
    config = function()
      require('nvim-autopairs').setup({
        disable_filetype = { 'TelescopePrompt', 'vim' },
        check_ts = true,
      })
    end,
  },
  {
    'L3MON4D3/LuaSnip',
    as = 'luasnip',
    requires = { 'saadparwaiz1/cmp_luasnip' },
    conf = 'luasnip',
  },
  {
    'hrsh7th/nvim-cmp',
    -- NOTE: referencing them as 'autopairs' and 'luasnip' is acceptable
    -- because I have them specifically defined as that via the `as` property
    -- above. Without that property, I would have to refer to them by their
    -- repo name exactly, so `nvim-autopairs` and `LuaSnip`
    after = { 'autopairs', 'luasnip' },
    requires = {
      'hrsh7th/cmp-nvim-lua',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-emoji',
      'hrsh7th/cmp-cmdline',
      'onsails/lspkind-nvim',
    },
    conf = 'cmp',
  },
  ------------------------------------------------------------------
  { 'ThePrimeagen/harpoon', conf = 'harpoon' },
  {
    'nvim-telescope/telescope.nvim',
    as = 'telescope',
    after = {
      -- 'noice',
      'trouble',
    },
    requires = {
      'nvim-lua/plenary.nvim', -- essential library
      'kyazdani42/nvim-web-devicons', -- file icons
      'nvim-telescope/telescope-live-grep-args.nvim',
      { 'dhruvmanila/telescope-bookmarks.nvim', tag = '*' },
      { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' },
    },
    conf = 'telescope',
  },
  {
    'ray-x/go.nvim',
    ft = { 'go' },
    config = function()
      require('go').setup()
    end,
  },
  ---- conflicts with noice
  {
    'vigoux/notifier.nvim',
    config = function()
      require('notifier').setup({
        notify = {
          clear_time = 5000,
          min_level = vim.log.levels.INFO,
        },
      })
    end,
  },
  {
    'neovim/nvim-lspconfig',
    as = 'lspconfig',
    after = { 'illumniate' },
    requires = {
      'jose-elias-alvarez/null-ls.nvim',
      'b0o/schemastore.nvim',
      'folke/neodev.nvim', -- better sumneko_lua settings
      'jose-elias-alvarez/typescript.nvim',
      'hrsh7th/nvim-cmp',
    },
    config = function()
      -- all LSP dependencies are loaded. Ready to setup...
      return require('jrnxf.lsp')
    end,
  },
  {
    'j-hui/fidget.nvim',
    config = function()
      require('fidget').setup({})
    end,
  },
  { 'RRethy/vim-illuminate', as = 'illumniate', conf = 'illuminate' }, -- highlights and allows moving between variable references
  {
    'williamboman/mason.nvim',
    after = 'lspconfig',
    requires = {
      'jose-elias-alvarez/null-ls.nvim',
      'williamboman/mason-lspconfig.nvim',
      -- '~/Dev/mason-tool-installer.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
    },
    conf = 'mason',
  },
  -- {
  --   'https://git.sr.ht/~whynothugo/lsp_lines.nvim',
  --   after = 'lspconfig',
  --   config = function()
  --     require('lsp_lines').setup()
  --   end,
  -- },
  {
    'lukas-reineke/indent-blankline.nvim',
    config = function()
      require('indent_blankline').setup({
        show_current_context = true,
        show_current_context_start = false, -- I don't like it underlining the top because I think it's an LSP warning
      })
      -- this brings it's own ugly rainbow lines, this corrects that
      vim.cmd([[colorscheme terafox]])
    end,
  },
  {
    'jose-elias-alvarez/null-ls.nvim',
    requires = 'nvim-lua/plenary.nvim',
  },
  {
    -- '~/Dev/trouble.nvim',
    -- 'thatvegandev/trouble.nvim', -- has my looping feature
    'folke/trouble.nvim',
    as = 'trouble',
    requires = 'kyazdani42/nvim-web-devicons',
    conf = 'trouble',
  },
  ---- {
  ----   'nvim-lualine/lualine.nvim',
  ----   -- after = 'noice',
  ----   conf = 'lualine',
  ---- },
  -- {
  --   'folke/noice.nvim',
  --   as = 'noice',
  --   conf = 'noice',
  --   requires = { 'MunifTanjim/nui.nvim' },
  -- },
  {
    'ibhagwan/fzf-lua',
    -- optional for icon support
    requires = { 'nvim-tree/nvim-web-devicons' },
  },
  {
    'sindrets/diffview.nvim',
    commit = 'bd6c0c2df6c00a72342f631a58e1ea28549b6ac8', -- bug with splits being horizontal by default rn
    conf = 'diffview',
    requires = 'nvim-lua/plenary.nvim',
  },
  {
    'akinsho/bufferline.nvim',
    tag = 'v3.*',
    conf = 'bufferline',
    requires = 'nvim-tree/nvim-web-devicons',
  },

  -- highlight colors
  -- {
  --   'brenoprata10/nvim-highlight-colors',
  --   config = function()
  --     require('nvim-highlight-colors').setup({
  --       render = 'first_column', -- or 'foreground' or 'first_column'
  --       enable_named_colors = true,
  --       enable_tailwind = true,
  --     })
  --   end,
  -- },
  {
    'norcalli/nvim-colorizer.lua',
    config = function()
      require('colorizer').setup()
    end,
  },
}

for _, plugin in pairs(plugins) do
  packer.use(plugin)
end

-- must be at EOF
if packer_bootstrap then
  require('packer').sync()
end

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

local use = packer.use
use('wbthomason/packer.nvim')

use('lewis6991/impatient.nvim')

use('tpope/vim-surround')

use('tpope/vim-commentary')

use('tpope/vim-fugitive')

use({
  'smjonas/inc-rename.nvim',
  config = function()
    require('inc_rename').setup({ preview_empty_name = true })
  end,
})

-- commenting out bc of noice
use({ 'stevearc/dressing.nvim', after = 'telescope', conf = 'dressing' })
-- use('rcarriga/nvim-notify')
-- use({ 'MunifTanjim/nui.nvim', conf = 'nui' })

use('folke/zen-mode.nvim')

use({
  'nvim-treesitter/nvim-treesitter',
  requires = { 'nvim-treesitter/playground' }, -- not required, but I like
  run = function()
    local ts_update = require('nvim-treesitter.install').update({ with_sync = true })
    ts_update()
  end,
  conf = 'treesitter',
})

-- automatically close jsx tags
use({ 'windwp/nvim-ts-autotag', ft = { 'typescript' } })

-- makes jsx comments actually work
use({ 'JoosepAlviste/nvim-ts-context-commentstring', ft = { 'typescript' } })

use({ 'karb94/neoscroll.nvim', conf = 'neoscroll' })

use({ 'ggandor/leap.nvim', conf = 'leap' })

use({
  'max397574/better-escape.nvim',
  config = function()
    require('better_escape').setup({ mapping = { 'jk', 'kj' } })
  end,
})

use({ 'EdenEast/nightfox.nvim', conf = 'nightfox' })
use({ 'rose-pine/neovim', as = 'rose-pine' })
use('rmehri01/onenord.nvim')
use('navarasu/onedark.nvim')
use('catppuccin/nvim')

use({
  'kyazdani42/nvim-tree.lua',
  requires = 'kyazdani42/nvim-web-devicons',
  conf = 'nvim-tree',
})

use({
  'feline-nvim/feline.nvim',
  event = 'VimEnter',
  conf = 'feline.init',
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
    require('gitsigns').setup()
  end,
})

-- use('rafamadriz/friendly-snippets')

-- Completion --------------------------------------------------
use({
  'windwp/nvim-autopairs',
  as = 'autopairs',
  config = function()
    require('nvim-autopairs').setup({
      disable_filetype = { 'TelescopePrompt', 'vim' },
      check_ts = true,
    })
  end,
})

use({
  'L3MON4D3/LuaSnip',
  as = 'luasnip',
  requires = { 'saadparwaiz1/cmp_luasnip' },
  conf = 'luasnip',
})

use({
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
    'hrsh7th/cmp-cmdline',
    'onsails/lspkind-nvim',
  },
  conf = 'cmp',
})
----------------------------------------------------------------

use({ 'ThePrimeagen/harpoon', conf = 'harpoon' })

use({
  'nvim-telescope/telescope.nvim',
  as = 'telescope',
  requires = {
    'nvim-lua/plenary.nvim', -- essential library
    'kyazdani42/nvim-web-devicons', -- file icons
    'xiyaowong/telescope-emoji.nvim', -- emoji picker
    'nvim-telescope/telescope-live-grep-args.nvim',
    { 'dhruvmanila/telescope-bookmarks.nvim', tag = '*' },
    { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' },
  },
  conf = 'telescope',
})

use({
  'ray-x/go.nvim',
  ft = { 'go' },
  config = function()
    require('go').setup()
  end,
})

-- conflicts with noice
-- use({
--   'vigoux/notifier.nvim',
--   config = function()
--     require('notifier').setup({
--       notify = {
--         clear_time = 5000,
--         min_level = vim.log.levels.INFO,
--       },
--     })
--   end,
-- })

use({
  'neovim/nvim-lspconfig',
  as = 'lspconfig',
  requires = {
    'jose-elias-alvarez/null-ls.nvim',
    'hrsh7th/nvim-cmp',
  },
  conf = 'lsp',
})

use({
  'williamboman/mason.nvim',
  after = 'lspconfig',
  requires = {
    'jose-elias-alvarez/null-ls.nvim',
    'williamboman/mason-lspconfig.nvim',
    'WhoIsSethDaniel/mason-tool-installer.nvim',
  },
  conf = 'mason',
})

use({
  'https://git.sr.ht/~whynothugo/lsp_lines.nvim',
  after = 'lspconfig',
  config = function()
    require('lsp_lines').setup()
  end,
})
use({
  'lukas-reineke/indent-blankline.nvim',
  config = function()
    require('indent_blankline').setup({
      show_current_context = true,
      show_current_context_start = false, -- I don't like it underlining the top because I think it's an LSP warning
    })
  end,
})

use({ 'jose-elias-alvarez/null-ls.nvim', requires = 'nvim-lua/plenary.nvim' })

use('jose-elias-alvarez/typescript.nvim')

-- doesn't work with noice bc commandline is buffer itself I think lol
-- use({ 'numtostr/BufOnly.nvim', cmd = 'BufOnly' })

use({
  -- '~/Dev/trouble.nvim',
  'thatvegandev/trouble.nvim',
  -- 'folke/trouble.nvim',
  requires = 'kyazdani42/nvim-web-devicons',
  conf = 'trouble',
})

use({
  'folke/noice.nvim',
  conf = 'noice',
  requires = { 'MunifTanjim/nui.nvim' },
})

-- TODO: Automatically set up your configuration after cloning packer.nvim
-- Put this at the end after all plugins
if packer_bootstrap then
  require('packer').sync()
end

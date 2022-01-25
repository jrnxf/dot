vim.cmd("packadd packer.nvim")
return require("packer").startup(function()
    use({ "wbthomason/packer.nvim", opt = true })

    local function conf(name)
        return require(string.format('plugins.conf.%s', name))
    end

    -- basic
    use "tpope/vim-surround"

    -- appearance
    use 'rmehri01/onenord.nvim'
    use {
        'kyazdani42/nvim-tree.lua',
        requires = {
          'kyazdani42/nvim-web-devicons',
        },
        config = conf 'nvim-tree'
    }
    use {
      'akinsho/nvim-bufferline.lua',
      config = conf 'nvim-bufferline'
    }
    use {
      'nvim-lualine/lualine.nvim',
      config = conf 'lualine'
    }
    -- search
    use {
        'nvim-telescope/telescope.nvim',
        requires = { {'nvim-lua/plenary.nvim'} },
        config = conf 'telescope'
      }
end)

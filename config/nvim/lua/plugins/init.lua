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

    -- search
    use {
        'nvim-telescope/telescope.nvim',
        requires = { {'nvim-lua/plenary.nvim'} },
        config = conf 'telescope'
      }
end)
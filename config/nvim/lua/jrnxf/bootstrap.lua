local M = {}

M.define_globals = function()
  -- Global state, config and function store for my config
  _G.jrn = {}

  -- Debug printing with vim.inspect. This needs to be defined before anything
  -- else as I use this throughout my config when debugging.
  _G.put = function(...)
    local objects = {}
    for i = 1, select('#', ...) do
      local v = select(i, ...)
      table.insert(objects, vim.inspect(v))
    end

    print(table.concat(objects, '\n'))
    return ...
  end
end

-- Disable some of the distributed plugins that are
-- shipped with neovim
M.disable_distibution_plugins = function()
  vim.g.loaded_gzip = 1
  vim.g.loaded_tar = 1
  vim.g.loaded_tarPlugin = 1
  vim.g.loaded_zip = 1
  vim.g.loaded_zipPlugin = 1
  vim.g.loaded_getscript = 1
  vim.g.loaded_getscriptPlugin = 1
  vim.g.loaded_vimball = 1
  vim.g.loaded_vimballPlugin = 1
  -- vim.g.loaded_matchit = 1
  -- vim.g.loaded_matchparen = 1
  vim.g.loaded_2html_plugin = 1
  vim.g.loaded_logiPat = 1
  vim.g.loaded_rrhelper = 1
  vim.g.loaded_netrw = 1
  vim.g.loaded_netrwPlugin = 1
  vim.g.loaded_netrwSettings = 1
  vim.g.loaded_netrwFileHandlers = 1
  vim.g.loaded_tutor_mode_plugin = 1
  vim.g.loaded_remote_plugins = 1
  vim.g.loaded_spellfile_plugin = 1
  vim.g.loaded_shada_plugin = 1
end

-- Entry point
M.init = function()
  M.define_globals()
  M.disable_distibution_plugins()

  pcall(require, 'impatient')

  require('jrnxf.core')
  require('jrnxf.plugins')
end

return M

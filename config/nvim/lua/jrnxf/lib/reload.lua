local M = {}

-- Reload all user config lua modules
M.full_reload = function()
  -- Handle impatient.nvim automatically.
  -- local luacache = (_G.__luacache or {}).cache

  -- local modlist = require('jrnxf.lib.modlist').getmodlist('jrnxf', { recurse = true })
  -- for _, name in ipairs(modlist) do
  --   if name ~= 'jrnxf.lib.reload' then
  --     package.loaded[name] = nil
  --     if luacache then
  --       luacache[name] = nil
  --     end
  --     print('cleared ' .. name)
  --   end
  -- end

  for name, _ in pairs(package.loaded) do
    -- core and plugins are namespaced under my lua folder
    -- since lua caches these modules, I need to manually set
    -- their values to nil in the cache to perform a full reload

    if name:match('^jrnxf.core') or name:match('^jrnxf.plugins') then
      package.loaded[name] = nil
    end
  end

  require('jrnxf.bootstrap').init()

  require('packer').sync()
end

return M

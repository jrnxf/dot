local platform = require("jrnxf.lib.platform")
local home = os.getenv("HOME")

local M = {}

-- Join a list of paths together
-- @param ... string list
-- @return string
M.join = function(...)
  return table.concat({ ... }, "/")
end

-- Define default values for important path locations
M.home = home
M.confighome = M.join(home, ".config", "nvim")
M.datahome = M.join(home, ".local", "share", "nvim")
M.cachehome = M.join(home, ".cache", "nvim")
M.packroot = M.join(M.cachehome, "site", "pack")
M.packer_compiled = M.join(M.datahome, "lua", "jrnxf", "compiled.lua")
M.module_path = M.join(M.confighome, "lua", "jrnxf", "plugins")

-- Create a directory
-- @param dir string
M.create_dir = function(dir)
  if not M.exists(dir) then
    vim.loop.fs_mkdir(dir, 511, function()
      assert("Failed to make path:" .. dir)
    end)
  end
end

-- Returns if the path exists on disk
-- @param path string
-- @return bool
M.exists = function(path)
  local stat = vim.loop.fs_stat(path)
  return not (stat == nil)
end

---Remove file from file system
---@param path string
M.remove_file = function(path)
  os.execute("rm " .. path)
end

jrn.path = M

return M

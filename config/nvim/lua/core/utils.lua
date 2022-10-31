local M = {}

M.is_git_dir = function()
  return os.execute('git rev-parse --is-inside-work-tree >> /dev/null 2>&1')
end

M.reload = function()
  for name, _ in pairs(package.loaded) do
    -- core, lsp, and plugins are namespaced under my lua folder
    -- since lua caches these modules, I need to manually set
    -- their values to nil in the cache to perform a full reload

    if name:match('^core') or name:match('^lsp') or name:match('^plugins') then
      package.loaded[name] = nil
    end
  end

  dofile(vim.env.MYVIMRC)
  require('packer').sync()
end

local default_map_options = { noremap = true, silent = true }

M.map = function(mode, key, cmd, opts)
  vim.api.nvim_set_keymap(mode, key, cmd, opts or default_map_options)
end

M.buf_map = function(bufnr, mode, key, cmd, opts)
  vim.api.nvim_buf_set_keymap(bufnr, mode, key, cmd, opts or default_map_options)
end

M.buf_command = function(bufnr, name, fn, opts)
  vim.api.nvim_buf_create_user_command(bufnr, name, fn, opts or {})
end

M.table = {
  some = function(tbl, cb)
    for k, v in pairs(tbl) do
      if cb(k, v) then
        return true
      end
    end
    return false
  end,
}

return M

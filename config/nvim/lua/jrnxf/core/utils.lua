local M = {}

M.is_git_dir = function()
  return os.execute('git rev-parse --is-inside-work-tree >> /dev/null 2>&1')
end

M.smart_telescope_files = function()
  local ts_builtin = require('telescope.builtin')
  if M.is_git_dir() == 0 then
    ts_builtin.git_files({ show_untracked = true })
  else
    ts_builtin.find_files()
  end
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

M.exec_file = function()
  local ft = vim.api.nvim_buf_get_option(0, 'filetype')
  vim.cmd('silent! write')

  if ft == 'lua' then
    vim.cmd('luafile %')
  elseif ft == 'python' then
    vim.cmd('!python %')
  elseif ft == 'vim' then
    vim.cmd('source %')
  end
end

-- Open url cross platform
M.open_url = function(url)
  local plat = jrn.platform
  if plat.is_mac then
    vim.cmd([[:execute 'silent !open ]] .. url .. "'")
  elseif plat.is_linux then
    vim.cmd([[:execute 'silent !xdg-open ]] .. url .. "'")
  else
    vim.notify('Unknown platform. Cannot open url')
  end
end

M.open_url_under_cursor = function()
  local cword = vim.fn.expand('<cWORD>')

  -- Remove surronding quotes if exist
  local url = string.gsub(cword, [[.*['"](.*)['"].*$]], '%1')

  -- If string starts with https://
  if string.match(url, [[^https://.*]]) then
    return M.open_url(url)
  end

  -- If string matches `user/repo`
  if string.match(url, [[.*/.*]]) then
    return M.open_url('https://github.com/' .. url)
  end
end

return M

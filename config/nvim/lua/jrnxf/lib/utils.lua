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

M.command = function(name, fn, opts)
  vim.api.nvim_create_user_command(name, fn, opts or {})
end

M.buf_command = function(bufnr, name, fn, opts)
  vim.api.nvim_buf_create_user_command(bufnr, name, fn, opts or {})
end

M.exec_current_file = function()
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

M.vec_union = function(...)
  local result = {}
  local seen = {}
  local args = { ... }

  for i = 1, #args do
    if args[i] ~= nil and type(args[i]) ~= 'boolean' then
      if type(args[i]) == 'table' then
        for k, v in pairs(args[i]) do
          if type(k) == 'number' and not seen[v] then
            seen[v] = true
            result[#result + 1] = v
          end
        end
      else
        if not seen[args[i]] then
          seen[args[i]] = true
          result[#result + 1] = args[i]
        -- not a table - but have I seen the value?
        else
        end
      end
    end
  end

  return result
end

M.tbl_deep_clone = function(t)
  local clone = {}

  for k, v in pairs(t) do
    if type(v) == 'table' then
      clone[k] = M.tbl_deep_clone(v)
    else
      clone[k] = v
    end
  end

  return clone
end

M.tbl_union_extend_overwrite = function(leftmost, ...)
  local res = {}

  local function recurse(base, next)
    -- this will place all array-like values in both table
    -- into one table. all values in the sub table after this
    -- operation will have number types
    local sub = M.vec_union(base, next)

    for k, v in pairs(base) do
      if type(k) ~= 'number' then
        sub[k] = v
      end
    end

    for k, v in pairs(next) do
      if type(k) ~= 'number' then
        if type(v) == 'table' then
          sub[k] = recurse(sub[k], v)
        else
          sub[k] = v
        end
      end
    end
    return sub
  end

  for _, next in pairs({ ... }) do
    res = recurse(M.tbl_deep_clone(leftmost), M.tbl_deep_clone(next))
  end

  return res
end

return M

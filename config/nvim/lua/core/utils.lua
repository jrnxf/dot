local M = {}

M.is_git_dir = function()
  return os.execute 'git rev-parse --is-inside-work-tree >> /dev/null 2>&1'
end

M.reload_nvim_conf = function()
  for name, _ in pairs(package.loaded) do
    -- core, lsp, and plugins are namespaced under my lua folder
    -- since lua caches these modules, I need to manually set
    -- their values to nil in the cache to perform a full reload!
    if name:match '^core' or name:match '^lsp' or name:match '^plugins' then
      package.loaded[name] = nil
    end
  end

  dofile(vim.env.MYVIMRC)
  vim.notify('Reloaded', vim.log.levels.INFO)
end

local options = { noremap = true, silent = true }

M.buf_map = function(bufnr, mode, key, cmd, opts)
  vim.api.nvim_buf_set_keymap(bufnr, mode, key, cmd, opts or options)
end

M.buf_command = function(bufnr, name, fn, opts)
  vim.api.nvim_buf_create_user_command(bufnr, name, fn, opts or {})
end

M.map = function(mode, key, cmd, opts)
  vim.api.nvim_set_keymap(mode, key, cmd, opts or options)
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

-- -- 'dir: up or down
-- -- TODO: see about sending in bufnr and being smart about
-- -- if the user wants to cycle a loclist or quickfix list
-- M.cycle_list = function(dir)
--   local wininfo = vim.fn.getwininfo()
--   local is_loclist_open = false
--   local is_quickfix_open = false

--   for _, win in pairs(wininfo) do
--     -- print(vim.inspect(win))
--     if win['loclist'] == 1 then
--       is_loclist_open = true
--     elseif win['quickfix'] == 1 then
--       is_quickfix_open = true
--     end
--   end

--   print('loclist open ' .. tostring(is_loclist_open))
--   print('quickfix open ' .. tostring(is_quickfix_open))
--   print(vim.buffer())

--   if is_loclist_open == true and dir == 'down' then
--     vim.cmd [[ lnext ]]
--   elseif is_loclist_open == true and dir == 'up' then
--     vim.cmd [[ lprev ]]
--   elseif is_quickfix_open == true and dir == 'down' then
--     vim.cmd [[ cnext ]]
--   elseif is_quickfix_open == true and dir == 'up' then
--     vim.cmd [[ cprev ]]
--   end
-- end

-- -- trying out Trouble
-- -- 'q': find the quickfix window
-- -- 'l': find all loclist windows
-- M.find_qf = function(type)
--   local wininfo = vim.fn.getwininfo()
--   local win_tbl = {}
--   for _, win in pairs(wininfo) do
--     local found = false
--     if type == 'l' and win['loclist'] == 1 then
--       found = true
--     end
--     -- loclist window has 'quickfix' set, eliminate those
--     if type == 'q' and win['quickfix'] == 1 and win['loclist'] == 0 then
--       found = true
--     end
--     if found then
--       table.insert(win_tbl, { winid = win['winid'], bufnr = win['bufnr'] })
--     end
--   end
--   return win_tbl
-- end

-- -- open quickfix if not empty
-- M.open_qf = function()
--   local qf_name = 'quickfix'
--   local qf_empty = function()
--     return vim.tbl_isempty(vim.fn.getqflist())
--   end
--   if not qf_empty() then
--     vim.cmd 'copen'
--     vim.cmd 'wincmd J'
--   else
--     print(string.format('%s is empty.', qf_name))
--   end
-- end

-- -- enum all non-qf windows and open
-- -- loclist on all windows where not empty
-- M.open_loclist_all = function()
--   local wininfo = vim.fn.getwininfo()
--   local qf_name = 'loclist'
--   local qf_empty = function(winnr)
--     return vim.tbl_isempty(vim.fn.getloclist(winnr))
--   end
--   for _, win in pairs(wininfo) do
--     if win['quickfix'] == 0 then
--       if not qf_empty(win['winnr']) then
--         -- switch active window before ':lopen'
--         vim.api.nvim_set_current_win(win['winid'])
--         vim.cmd 'lopen'
--       else
--         print(string.format('%s is empty.', qf_name))
--       end
--     end
--   end
-- end

-- -- Can also use #T ?
-- M.tablelength = function(T)
--   local count = 0
--   for _ in pairs(T) do
--     count = count + 1
--   end
--   return count
-- end

-- -- toggle quickfix/loclist on/off
-- -- type='*': qf toggle and send to bottom
-- -- type='l': loclist toggle (all windows)
-- M.toggle_qf = function(type)
--   local windows = M.find_qf(type)
--   if M.tablelength(windows) > 0 then
--     -- hide all visible windows
--     for _, win in pairs(windows) do
--       vim.api.nvim_win_hide(win.winid)
--     end
--   else
--     -- no windows are visible, attempt to open
--     if type == 'l' then
--       M.open_loclist_all()
--     else
--       M.open_qf()
--     end
--   end
-- end
return M

-- vim.api.nvim_create_autocmd('VimEnter', {
--   callback = function(args)
--     -- this function detects if we're in
--     if vim.fn.isdirectory(args.file) ~= 0 then
--       vim.api.nvim_buf_delete(0, { force = true })
--       -- u.smart_telescope_files() -- i'd rather just press <C-p> if I want this
--     end
--   end,
-- })

vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank({ timeout = 200 })
  end,
})

vim.api.nvim_create_autocmd('DiagnosticChanged', {
  -- add buffer diagnostics to the location list
  -- DiagnosticChanged = after diagnostics have changed
  -- BufEnter = after entering a buffer (ensures the loclist updates as I move around)
  --      TODO figure out why adding BufEnter as (DiagnosticChanged,BufEnter) makes
  --      it so the location list wont close, and I can't cycle through it
  callback = function()
    vim.diagnostic.setloclist({ open = false })
  end,
})

vim.cmd('au User FugitiveIndex nmap <buffer> dt :Gtabedit <Plug><cfile><Bar>Gdiffsplit<CR>')

vim.cmd('command! LuaSnipEdit lua require("luasnip.loaders.from_lua").edit_snippet_files()')

local u = require('core.utils')

vim.api.nvim_create_autocmd('VimEnter', {
  callback = function(args)
    if vim.fn.isdirectory(args.file) ~= 0 then
      vim.api.nvim_buf_delete(0, { force = true })
      u.smart_telescope_files()
    end
  end,
})

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

vim.cmd('command! FullReload lua require("core.utils").full_reload()')

vim.cmd('command! LspFormatting lua vim.lsp.buf.format()')
vim.cmd('command! LspCodeAction lua vim.lsp.buf.code_action()')
vim.cmd('command! LspHover lua vim.lsp.buf.hover()')
vim.cmd('command! LspRename lua vim.lsp.buf.rename()')
vim.cmd('command! LspTypeDefinition lua vim.lsp.buf.type_definition()')
vim.cmd('command! LspSignatureHelp lua vim.lsp.buf.signature_help()')
vim.cmd('command! LspDiagQuickfix lua vim.diagnostic.setqflist()')
vim.cmd('command! LspDiagLoclist lua vim.diagnostic.setloclist()')
vim.cmd('command! LspDiagPrev lua vim.diagnostic.goto_prev()')
vim.cmd('command! LspDiagNext lua vim.diagnostic.goto_next()')
vim.cmd('command! LspDiagFloat lua vim.diagnostic.open_float()')

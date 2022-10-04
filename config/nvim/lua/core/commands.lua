function Sad(line_nr, from, to, fname)
  vim.cmd(string.format("silent !sed -i'.bak' '%ss/%s/%s/' %s && rm -rf %s.bak", line_nr, from, to, fname, fname))
end

function IncreasePadding()
  Sad('06', 0, 10, '~/dotfiles/config/alacritty/alacritty.yml')
  Sad('07', 0, 10, '~/dotfiles/config/alacritty/alacritty.yml')
end

function DecreasePadding()
  Sad('06', 10, 0, '~/dotfiles/config/alacritty/alacritty.yml')
  Sad('07', 10, 0, '~/dotfiles/config/alacritty/alacritty.yml')
end

vim.cmd [[
  augroup ChangeAlacrittyPadding
   au! 
   au VimEnter * lua DecreasePadding()
   au VimLeavePre * lua IncreasePadding()
  augroup END 
]]

vim.cmd [[
    augroup highlight_yank
      au!
      au TextYankPost * silent! lua vim.highlight.on_yank { timeout = 200 }
    augroup END
]]
-- add this command to the user defined commands
vim.cmd 'command! NvimReload lua require"core.utils".reload_nvim_conf()'

-- add buffer diagnostics to the location list
-- DiagnosticChanged = after diagnostics have changed
-- BufEnter = after entering a buffer (ensures the loclist updates as I move around)
--      TODO figure out why adding BufEnter as (DiagnosticChanged,BufEnter) makes
--      it so the location list wont close, and I can't cycle through it
vim.cmd [[ au DiagnosticChanged  * lua vim.diagnostic.setloclist({ open = false }) ]]

vim.cmd 'command! LspDeclaration lua vim.lsp.buf.declaration()'
vim.cmd 'command! LspDefinition lua vim.lsp.buf.definition()'
vim.cmd 'command! LspFormatting lua vim.lsp.buf.formatting()'
vim.cmd 'command! LspCodeAction lua vim.lsp.buf.code_action()'
vim.cmd 'command! LspHover lua vim.lsp.buf.hover()'
vim.cmd 'command! LspRename lua vim.lsp.buf.rename()'
vim.cmd 'command! LspReferences lua vim.lsp.buf.references()'
vim.cmd 'command! LspTypeDefinition lua vim.lsp.buf.type_definition()'
vim.cmd 'command! LspImplementation lua vim.lsp.buf.implementation()'
vim.cmd 'command! LspSignatureHelp lua vim.lsp.buf.signature_help()'
vim.cmd 'command! LspDiagQuickfix lua vim.diagnostic.setqflist()'
vim.cmd 'command! LspDiagLoclist lua vim.diagnostic.setloclist()'
vim.cmd 'command! LspDiagPrev lua vim.diagnostic.goto_prev()'
vim.cmd 'command! LspDiagNext lua vim.diagnostic.goto_next()'
vim.cmd 'command! LspDiagFloat lua vim.diagnostic.open_float()'

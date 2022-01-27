vim.cmd [[
    augroup ftplugin
      au!
      au FileType man setl laststatus=0 noruler
      au FileType vim,css,javascript,lua,sh,zsh setl sw=2
      au TermOpen term://* setl nornu nonu nocul so=0 scl=no
    augroup END

    augroup save_on_insert_leave
      au!
      au InsertLeave * update
    augroup END

    augroup highlight_yank
      au!
      au TextYankPost * silent! lua vim.highlight.on_yank { timeout = 150 }
    augroup END
]]




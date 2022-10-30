local u = require 'core.utils'

require('fzf-lua').setup {
  keymap = {
    fzf = {
      ['ctrl-q'] = 'select-all+accept',
    },
  },
  winopts = {
    height = 0.95,
    width = 0.95,
    preview = {
      scrollbar = false,
    },
  },
  fzf_opts = {
    ['--layout'] = 'default',
  },
}

if u.is_git_dir() == 0 then
  u.map('n', '<leader>f', '<cmd>FzfLua git_files<CR>')
else
  u.map('n', '<leader>f', '<cmd>FzfLua files<CR>')
end
u.map('n', '<leader>fw', '<cmd>FzfLua live_grep_native<CR>')
u.map('n', '<leader>fo', '<cmd>FzfLua oldfiles<CR>')
u.map('n', '<leader>cw', '<cmd>FzfLua grep_cWORD<CR>')
u.map('n', '<leader><leader>', '<cmd>FzfLua buffers<CR>')

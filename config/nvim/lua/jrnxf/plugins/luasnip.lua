local ls = require('luasnip')

local types = require('luasnip.util.types')
require('luasnip.loaders.from_lua').load({ paths = '~/.config/nvim/snippets/' })
require('luasnip.loaders.from_vscode').lazy_load()

ls.config.set_config({
  history = true, -- keep around last snippet local ks jump back
  updateevents = 'TextChanged,TextChangedI',
  enable_autosnippets = true,
  ext_opts = {
    [types.choiceNode] = {
      active = {
        virt_text = { { '←', 'Error' } },
      },
    },
  },
})

vim.keymap.set({ 'i', 's' }, '<C-k>', function()
  if ls.expand_or_jumpable() then
    ls.expand_or_jump()
  end
end, { silent = true })

vim.keymap.set({ 'i', 's' }, '<C-j>', function()
  if ls.jumpable(-1) then
    ls.jump(-1)
  end
end, { silent = true })

-- shortcut to source luasnips file agau, which will reload snippets

nmap('<leader><leader>s', '<cmd>source ~/.config/nvim/lua/plugins/luasnip.lua<CR>')

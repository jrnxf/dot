require('legendary').setup({
  keymaps = {
    -- map keys to a command
    -- { '<leader>ff', ':Telescope find_files', description = 'Find files' },
    { '<leader>fr', ':FullReload', description = 'Full Reload' },
    -- map keys to a function
    -- keymaps have opts.silent = true by default, but you can override it
    { '<leader>s', ':SomeCommand<CR>', description = 'Non-silent keymap', opts = { silent = false } },
    -- create keymaps with different implementations per-mode
    {
      '<leader>c',
      { n = ':LinewiseCommentToggle<CR>', x = ":'<,'>BlockwiseCommentToggle<CR>" },
      description = 'Toggle comment',
    },
  },
  commands = {
    -- easily create user commands
    {
      ':SayHello',
      function()
        print('hello world!')
      end,
      description = 'Say hello as a command',
    },
  },
  autocmds = {
    -- Create autocmds and augroups
    { 'BufWritePre', vim.lsp.buf.format, description = 'Format on save' },
    {
      name = 'MyAugroup',
      clear = true,
      -- autocmds here
    },
  },
  -- functions = {
  --   -- Make arbitrary Lua functions that can be executed via the item finder
  --   { function() doSomeStuff() end, description = 'Do some stuff with a Lua function!' },
  -- },
})

nmap('<leader>l', ':Legendary<CR>')

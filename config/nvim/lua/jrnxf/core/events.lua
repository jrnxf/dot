require('jrnxf.lib.events')

augroup('user_events', {
  -- Highlight yank with `IncSearch`
  {
    event = 'TextYankPost',
    exec = function()
      vim.highlight.on_yank({ hlgroup = 'IncSearch', timeout = 300 })
    end,
  },
})

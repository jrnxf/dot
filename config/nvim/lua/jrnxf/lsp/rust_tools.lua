local rt = require('rust-tools')

local M = {}

M.setup = function(on_attach, capabilities)
  rt.setup({
    server = {
      on_attach = function(client, bufnr)
        -- Hover actions
        vim.keymap.set('n', '<C-space>', rt.hover_actions.hover_actions, { buffer = bufnr })
        -- Code action groups
        vim.keymap.set('n', '<Leader>a', rt.code_action_group.code_action_group, { buffer = bufnr })
        on_attach(client, bufnr)
      end,
    },
  })
end
return M

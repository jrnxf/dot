local null_ls = require("null-ls")
local b = null_ls.builtins

local sources = {
    -- formatting
    b.formatting.prettierd,
    b.formatting.shfmt,
      b.formatting.stylua,
    -- code actions
    b.code_actions.shellcheck,
    b.code_actions.xo,
    b.code_actions.gitsigns,
    -- hover
    b.hover.dictionary,
    b.hover.printenv,
}

local M = {}
M.setup = function(on_attach)
    null_ls.setup({
        border = "rounded",
        -- debug = true,
        sources = sources,
        on_attach = on_attach,
    })
end

return M

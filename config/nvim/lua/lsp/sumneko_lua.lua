local settings = {
    Lua = {
        diagnostics = {
            globals = {
                "global",
                "vim",
                "use",
                "describe",
                "it",
                "assert",
                "before_each",
                "after_each",
            },
        },
        completion = {
            showWord = "Disable",
            callSnippet = "Disable",
            keywordSnippet = "Disable",
        },
    },
}

local M = {}

M.opts = function(on_attach, capabilities)
    local luadev = require("lua-dev").setup({
        lspconfig = {
            on_attach = on_attach,
            capailities = capabilities,
            settings = settings,
            flags = {
                debounce_text_changes = 150,
            },
        },
    })
    return luadev
end

return M

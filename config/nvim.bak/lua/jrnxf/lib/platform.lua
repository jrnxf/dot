local M = {}

local uname = vim.loop.os_uname()

M.is_mac = uname.sysname == "Darwin"
M.is_linux = uname.sysname == "Linux"

jrn.platform = M

return M

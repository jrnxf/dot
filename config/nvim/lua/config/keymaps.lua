-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--
local Util = require("lazyvim.util")

vim.api.nvim_set_keymap("i", "<C-c>", "<Esc>", { silent = true })
vim.api.nvim_set_keymap("i", "<Tab>", "<Plug>(TaboutMulti)", { silent = true })
vim.api.nvim_set_keymap("i", "<S-Tab>", "<Plug>(TaboutBackMulti)", { silent = true })

vim.keymap.set("n", "<leader>ft", function()
  Util.float_term(nil, { border = "rounded", cwd = Util.get_root() })
end, { desc = "Terminal (root dir)" })
vim.keymap.set("n", "<leader>fT", function()
  Util.float_term(nil, { border = "rounded" })
end, { desc = "Terminal (cwd)" })

vim.keymap.set("n", "<leader>/", function()
  require("telescope").extensions.live_grep_args.live_grep_args()
end, { desc = "Live Grep (Args)" })

-- You probably also want to set a keymap to toggle aerial
vim.keymap.set("n", "<leader>a", "<cmd>AerialToggle!<CR>")

-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

local function augroup(name)
  return vim.api.nvim_create_augroup("lazyvim_" .. name, { clear = true })
end

-- close some filetypes with <c-c>
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("close_with_ctrl_c"),
  pattern = {
    "PlenaryTestPopup",
    "fzf",
    "help",
    "lspinfo",
    "man",
    "mason",
    "noice",
    "notify",
    "qf",
    "spectre_panel",
    "startuptime",
    "tsplayground",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("t", "<C-c>", "<C-c>", { buffer = event.buf, silent = true })
    vim.keymap.set("n", "<C-c>", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end,
})

-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

local function augroup(name, opts)
  return vim.api.nvim_create_augroup("jrnxf_" .. name, opts or { clear = false })
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
    "null-ls-info",
    "qf",
    "spectre_panel",
    "startuptime",
    "tsplayground",
    "Trouble",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("t", "<C-c>", "<C-c>", { buffer = event.buf, silent = true })
    vim.keymap.set("n", "<C-c>", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = augroup("go_to_def_help"),
  pattern = { "help" },
  callback = function()
    vim.keymap.set("n", "gd", "<c-]>")
  end,
})

local remember_folds_group = augroup("remember_folds")

vim.api.nvim_create_autocmd("BufWinLeave", {
  group = remember_folds_group,
  pattern = { "*.*" },
  callback = function()
    vim.cmd.mkview()
  end,
})

vim.api.nvim_create_autocmd("BufWinEnter", {
  group = remember_folds_group,
  pattern = { "*.*" },
  callback = function()
    vim.cmd.loadview({ mods = { emsg_silent = true } })
  end,
})

vim.api.nvim_create_autocmd("ExitPre", {
  group = remember_folds_group,
  pattern = { "*" },
  callback = function(event)
    vim.notify(vim.inspect(event))
  end,
})

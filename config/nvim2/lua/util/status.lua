-- @ref https://github.com/folke/dot/blob/master/config/nvim/lua/util/status.lua (modified)
local M = {}
_G.Status = M

---@return {name:string, text:string, texthl:string}[]
function M.get_signs()
  local buf = vim.api.nvim_win_get_buf(vim.g.statusline_winid)
  return vim.tbl_map(function(sign)
    return vim.fn.sign_getdefined(sign.name)[1]
  end, vim.fn.sign_getplaced(buf, { group = "*", lnum = vim.v.lnum })[1].signs)
end

function M.statuscolumn()
  local diagnostic_sign, git_sign

  for _, s in ipairs(M.get_signs()) do
    if s.name:find("GitSign") then
      git_sign = s
    elseif s.name:find("Diagnostic") then
      diagnostic_sign = s
    end
  end

  -- the git and diag icons all have an extra " " at the end, so :sub(1, -2) removes that, allowing for a thinner statuscolumn
  local diagnostic_column = diagnostic_sign and ("%#" .. diagnostic_sign.texthl .. "#" .. diagnostic_sign.text:sub(1, -2) .. "%*") or " "
  local git_column = git_sign and ("%#" .. git_sign.texthl .. "#" .. git_sign.text:sub(1, -2) .. "%*") or " "

  local number_text = " "
  local number = vim.api.nvim_win_get_option(vim.g.statusline_winid, "number")
  if number and vim.wo.relativenumber and vim.v.virtnum == 0 then
    number_text = vim.v.relnum == 0 and vim.v.lnum or vim.v.relnum
  end

  -- right-aligned number column (thanks to the %=)
  -- %= @ref :h statusline "Separation point between alignment sections. Each section will be separated by an equal number of spaces
  local number_column = "%=" .. number_text .. " "

  -- local fold_column = " " .. "%C" .. " " -- make sure fold column is set to "1" if this is used
  local fold_column = "%C" -- make sure fold column is set to "1" if this is used

  local columns = {
    diagnostic_column,
    number_column,
    git_column,
    fold_column,
  }

  return table.concat(columns, "")
end

if vim.fn.has("nvim-0.9.0") == 1 then
  vim.opt.foldcolumn = "1"
  vim.opt.statuscolumn = [[%!v:lua.Status.statuscolumn()]]
end

return M

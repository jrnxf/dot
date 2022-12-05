local M = {}

local get_map_options = function(custom_options)
  local options = { silent = true, remap = false } -- defaults
  if custom_options then
    options = vim.tbl_extend('force', options, custom_options)
  end
  return options
end

M.map = function(mode, input, source, opts)
  vim.keymap.set(mode, input, source, get_map_options(opts))
end

for _, mode in ipairs({ 'n', 'o', 'i', 'x', 't', 'v', 'c' }) do
  M[mode .. 'map'] = function(...)
    M.map(mode, ...)
  end
end

M.buf_map = function(bufnr, mode, target, source, opts)
  opts = opts or {}
  opts.buffer = bufnr

  M.map(mode, target, source, get_map_options(opts))
end

_G.kmap = M.map
_G.nmap = M.nmap
_G.imap = M.imap
_G.vmap = M.vmap
_G.cmap = M.cmap
_G.xmap = M.xmap
_G.omap = M.omap
_G.smap = M.smap
_G.tmap = M.tmap
_G.buf_map = M.buf_map

return M

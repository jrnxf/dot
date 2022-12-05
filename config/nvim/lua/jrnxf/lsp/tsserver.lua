local u = require('jrnxf.lib.utils')

local api = vim.api

-- const myString = "hello ${}" ->
-- const myString = `hello ${}`
local change_template_string_quotes = function()
  local row, col = unpack(api.nvim_win_get_cursor(0))
  row = row - 1

  local quote_start, quote_end
  u.gfind(api.nvim_get_current_line(), '["\']', function(pos)
    if not quote_start then
      -- start at first quote
      quote_start = pos
    elseif pos < col then
      -- move start if quote is closer to col
      if (pos - col) > (quote_start - col) then
        quote_start = pos
      end
    elseif not quote_end then
      -- first quote after col is end
      quote_end = pos
    end
  end)

  -- if found, replace quotes with backticks
  if quote_start and quote_start <= col and quote_end then
    api.nvim_buf_set_text(0, row, quote_start - 1, row, quote_start, { '`' })
    api.nvim_buf_set_text(0, row, quote_end - 1, row, quote_end, { '`' })
  end

  -- input and move cursor into pair
  u.input('${}', 'n')
  u.input('<Left>')
end

-- padding: 40px; ->
-- padding: "40px",
local css_to_js = function(opts)
  local start_line, end_line
  if type(opts) == 'table' then
    -- called via command
    start_line, end_line = opts.line1 - 1, opts.line2
  else
    -- called as operator
    start_line = api.nvim_buf_get_mark(0, '[')[1] - 1
    end_line = api.nvim_buf_get_mark(0, ']')[1] + 1
  end

  local did_convert = false
  for i, line in ipairs(api.nvim_buf_get_lines(0, start_line, end_line, false)) do
    -- if the line ends in a comma, it's probably already js
    if line:sub(#line) == ',' then
      goto continue
    end
    -- ignore comments
    if line:find('%/%*') then
      goto continue
    end

    local indentation, name, val = line:match('(%s+)(.+):%s(.+)')
    -- skip non-matching lines
    if not (name and val) then
      goto continue
    end

    local parsed_name = ''
    for j, component in ipairs(vim.split(name, '-')) do
      parsed_name = parsed_name .. (j == 1 and component or (component:sub(1, 1):upper() .. component:sub(2)))
    end

    local parsed_val = val:gsub(';', '')
    -- keep numbers, wrap others in quotes
    parsed_val = tonumber(parsed_val) or string.format('"%s"', parsed_val)
    local parsed_line = table.concat({ indentation, parsed_name, ': ', parsed_val, ',' })

    did_convert = true
    local row = start_line + i
    api.nvim_buf_set_lines(0, row - 1, row, false, { parsed_line })

    ::continue::
  end

  if not did_convert then
    vim.notify('css-to-js: nothing to convert', vim.log.levels.WARN)
  end
end

local M = {}
M.setup = function(on_attach, capabilities)
  require('typescript').setup({
    server = {
      on_attach = function(client, bufnr)
        on_attach(client, bufnr)

        u.buf_map(bufnr, 'n', 'go', ':TypescriptAddMissingImports<CR>')
        u.buf_map(bufnr, 'n', 'gO', ':TypescriptOrganizeImports<CR>')
        u.buf_map(bufnr, 'n', 'gI', ':TypescriptRenameFile<CR>')

        u.buf_map(bufnr, 'i', '${', change_template_string_quotes, { nowait = true })

        u.buf_command(bufnr, 'CssToJs', css_to_js, { range = true })
        -- u.buf_map(bufnr, "n", "gx", ":set opfunc=v:lua.css_to_js<CR>g@")
        -- u.buf_map(bufnr, "n", "gxx", ":CssToJs<CR>")
        -- u.buf_map(bufnr, "v", "gx", ":CssToJs<CR>")

        -- override (doesn't work in pocus- typescript needs updating)
        -- u.buf_map(bufnr, 'n', 'gd', ':TypescriptGoToSourceDefinition<CR>')
      end,
      capabilities = capabilities,
    },
  })
end

return M

local ls = require('luasnip')
local s = ls.s
local i = ls.i
local t = ls.t

local d = ls.dynamic_node
local c = ls.choice_node
local f = ls.function_node
local sn = ls.snippet_node

local fmt = require('luasnip.extras.fmt').fmt
local rep = require('luasnip.extras').rep

local snippets = {
  s(
    'cl',
    fmt([[console.log({})]], {
      i(1),
    })
  ),
  s(
    'imp',
    fmt([[import {{ {} }} from "{}"]], {
      i(2),
      i(1),
    })
  ),
}

return snippets, nil

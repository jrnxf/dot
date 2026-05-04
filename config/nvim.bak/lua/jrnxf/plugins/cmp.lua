local cmp = require('cmp')
local lspkind = require('lspkind')
local cmp_autopairs = require('nvim-autopairs.completion.cmp')
local luasnip = require('luasnip')

-- NOTE: Lua 5.1 compatibility
-- @ref (https://github.com/hrsh7th/nvim-cmp/issues/1017#issuecomment-1141440976)
---@diagnostic disable-next-line: deprecated
table.unpack = table.unpack or unpack -- 5.1 compatibility

local has_words_before = function()
  local line, col = table.unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match('%s') == nil
end

cmp.setup({
  window = {
    completion = { -- rounded border; thin-style scrollbar
      border = { '╭', '─', '╮', '│', '╯', '─', '╰', '│' },
      winhighlight = 'Normal:CmpPmenu,FloatBorder:CmpPmenuBorder,CursorLine:PmenuSel,Search:None',
    },
    documentation = { -- no border; native-style scrollbar
      border = 'rounded',
      winhighlight = 'Normal:CmpPmenu,FloatBorder:CmpPmenuBorder,CursorLine:PmenuSel,Search:None',
    },
  },
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  formatting = {
    format = lspkind.cmp_format({
      mode = 'symbol_text',

      menu = {
        nvim_lsp = '[lsp]',
        buffer = '[buf]',
        nvim_lua = '[lua]',
        luasnip = '[snp]',
        path = '[path]',
      },
    }),
  },
  -- this is actually kinda visually distracting
  -- experimental = {
  --   ghost_text = true,
  -- },
  mapping = {
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-d>'] = cmp.mapping.scroll_docs(1), -- down
    ['<C-u>'] = cmp.mapping.scroll_docs(-1), -- up
    -- ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    }),
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      elseif has_words_before() then
        cmp.complete()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  },
  -- Sources order are actually their priority order
  sources = {
    { name = 'nvim_lsp' },
    { name = 'buffer' },
    { name = 'nvim_lua' },
    { name = 'luasnip' },
    { name = 'treesitter' },
    { name = 'path' },
    { name = 'emoji' },
  },
})

cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())

-- this one drives me crazy lol
-- cmp.setup.cmdline('/', {
--   mapping = cmp.mapping.preset.cmdline(),
--   sources = {
--     { name = 'buffer' },
--   },
-- })

-- `:` cmdline setup.
cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' },
  }, {
    {
      name = 'cmdline',
      option = {
        ignore_cmds = { 'Man', '!' },
      },
    },
  }),
})

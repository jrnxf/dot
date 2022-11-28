local cmp = require('cmp')
local lspkind = require('lspkind')
local cmp_autopairs = require('nvim-autopairs.completion.cmp')

-- NOTE: Lua 5.1 compatibility
-- @ref (https://github.com/hrsh7th/nvim-cmp/issues/1017#issuecomment-1141440976)
---@diagnostic disable-next-line: deprecated
table.unpack = table.unpack or unpack -- 5.1 compatibility

local has_words_before = function()
  local line, col = table.unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match('%s') == nil
end

cmp.setup({
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  formatting = {
    format = lspkind.cmp_format({
      with_text = false,
      menu = {
        luasnip = '[snp]',
        buffer = '[buf]',
        nvim_lsp = '[lsp]',
        nvim_lua = '[api]',
        path = '[path]',
      },
    }),
  },
  experimental = {
    ghost_text = true,
  },
  mapping = {
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-d>'] = cmp.mapping.scroll_docs(1), -- down
    ['<C-u>'] = cmp.mapping.scroll_docs(-1), -- up
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.close(),
    ['<CR>'] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    }),
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif has_words_before() then
        cmp.complete()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      else
        fallback()
      end
    end, { 'i', 's' }),
  },
  -- Sources order are actually their priority order
  sources = {
    { name = 'luasnip' },
    { name = 'nvim_lua' },
    { name = 'nvim_lsp' },
    { name = 'treesitter' },
    { name = 'path' },
    { name = 'emoji' },
    {
      name = 'buffer',
      keyword_length = 5,
      option = {
        get_bufnr = function() -- all buffers
          return vim.api.nvim_list_bufs()
        end,
      },
    },
  },
})

cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())

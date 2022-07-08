local cmp = require('cmp')

local has_words_before = function()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match('%s') == nil
end

local next_item = function(fallback)
  if cmp.visible() then
    cmp.select_next_item()
  elseif has_words_before() then
    cmp.complete()
  else
    fallback()
  end
end

local previous_item = function(fallback)
  if cmp.visible() then
    cmp.select_prev_item()
  end
end

cmp.setup({
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
    end,
  },
  mapping = {
    ['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), {'i', 'c'}),
    ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), {'i', 'c'}),
    ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), {'i', 'c'}),
    ['<Tab>'] = cmp.mapping(next_item, {'i', 's'}),
    ['<S-Tab>'] = cmp.mapping(previous_item, {'i', 's'}),
    ['<CR>'] = cmp.mapping.confirm({select = true}),
  },
  sources = cmp.config.sources({
    {name = 'nvim_lsp'},
    {name = 'buffer'},
    {name = 'path'},
  })
})

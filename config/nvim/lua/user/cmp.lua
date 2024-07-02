local cmp = require('cmp')
local use = require('utils').use;

local has_words_before = function()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_text(0, line - 1, 0, line - 1, col, {})[1]:match("^%s*$") == nil
end

local next_item = function(fallback)
  if cmp.visible() then
    cmp.select_next_item({behavior = cmp.SelectBehavior.Select})
  elseif has_words_before() then
    cmp.complete()
  else
    fallback()
  end
end

local previous_item = function(_)
  if cmp.visible() then
    cmp.select_prev_item()
  end
end

use('copilot', function(copilot)
  copilot.setup({
    panel = {enabled = false},
    suggestion = {enabled = false},
    filetypes = {
      javascript = true,
      perl = true,
      typescript = true,
      rust = true,
      cvs = false,
      gitcommit = false,
      gitrebase = false,
      help = false,
      hgcommit = false,
      markdown = false,
      svn = false,
      yaml = false,
      sh = function ()
        if string.match(vim.api.nvim_buf_get_name(0), 'env') then return false else return true end
      end,
      ["."] = false,
      ["*"] = false, -- Do not want to enable copilot for "pass edit", yaml config, and other sensitive files
    },
    copilot_node_command = 'node', -- Node.js version must be > 18.x
    server_opts_overrides = {},
  })
  require('copilot_cmp').setup()
end)

cmp.setup({
  preselect = cmp.PreselectMode.None,
  snippet = {
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body)
    end,
  },
  mapping = {
    ['<C-S-f>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), {'i', 'c'}),
    ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), {'i', 'c'}),
    ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), {'i', 'c'}),
    ['<Tab>'] = cmp.mapping(next_item, {'i', 's'}),
    ['<S-Tab>'] = cmp.mapping(previous_item, {'i', 's'}),
    ['<CR>'] = cmp.mapping.confirm({select = true}),
  },
  sources = cmp.config.sources({
    {name = 'copilot'},
    {name = 'nvim_lsp', keyword_length = 2},
    {name = 'vsnip'},
    {name = 'path', keyword_length = 2, trigger_characters = {'.', '/'}},
    {name = 'buffer', keyword_length = 1},
    {name = 'calc'},
  }),
  window = {
    documentation = {
      max_height = 15,
      max_width = 80,
      completion = cmp.config.window.bordered(),
      documentation = cmp.config.window.bordered(),
    },
  },
})

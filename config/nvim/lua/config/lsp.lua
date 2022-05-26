-- vim.lsp.set_log_level('debug')
local utils = require('../utils')
utils.autocmd('filetypes', {{'BufRead,BufNewFile', '*.css', 'set filetype=scss'}})

local function on_attach(client, bufnr)
  vim.o.updatetime = 300
  vim.o.omnifunc = 'v:lua.vim.lsp.omnifunc'

  local opts = {noremap = true, silent = true}
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
end

local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
local lspconfig = require('lspconfig')

lspconfig.bashls.setup({capabilities = capabilities, on_attach = on_attach})
lspconfig.cssls.setup({capabilities = capabilities, on_attach = on_attach})
lspconfig.html.setup({capabilities = capabilities, on_attach = on_attach})
lspconfig.perlpls.setup({capabilities = capabilities, on_attach = on_attach});
lspconfig.svelte.setup({capabilities = capabilities, on_attach = on_attach})
lspconfig.tsserver.setup({capabilities = capabilities, on_attach = on_attach})
lspconfig.vuels.setup({capabilities = capabilities, on_attach = on_attach})
lspconfig.yamlls.setup({capabilities = capabilities, on_attach = on_attach})

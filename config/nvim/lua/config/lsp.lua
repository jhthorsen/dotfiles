-- vim.lsp.set_log_level('debug')
local cmd = vim.cmd
cmd('autocmd BufRead,BufNewFile *.css set filetype=scss')
cmd('autocmd CursorHold,CursorHoldI * lua vim.diagnostic.open_float(nil, {focus=false})')

vim.diagnostic.config({virtual_text = false})

local function on_attach(client, bufnr)
  vim.o.updatetime = 300
  vim.o.omnifunc = 'v:lua.vim.lsp.omnifunc'

  local opts = {buffer = bufnr, noremap = true, silent = true}
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
  vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
  vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, opts)
end

local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
local lspconfig = require('lspconfig')

local volar_init_options = {
  typescript = {
    serverPath = '/opt/homebrew/lib/node_modules/typescript/lib/tsserverlibrary.js'
  }
}

lspconfig.bashls.setup({capabilities = capabilities, on_attach = on_attach})
lspconfig.cssls.setup({capabilities = capabilities, on_attach = on_attach})
lspconfig.html.setup({capabilities = capabilities, on_attach = on_attach})
lspconfig.perlpls.setup({capabilities = capabilities, on_attach = on_attach});
lspconfig.svelte.setup({capabilities = capabilities, on_attach = on_attach})
lspconfig.tsserver.setup({capabilities = capabilities, on_attach = on_attach})
lspconfig.volar.setup({capabilities = capabilities, on_attach = on_attach, init_options = volar_init_options})
lspconfig.yamlls.setup({capabilities = capabilities, on_attach = on_attach})

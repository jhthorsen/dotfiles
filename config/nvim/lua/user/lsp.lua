local use = require('../utils').use;
local cmd = vim.cmd

cmd('autocmd BufRead,BufNewFile *.css set filetype=scss')
cmd('autocmd BufRead,BufNewFile *.pcss set filetype=scss')

vim.diagnostic.config({virtual_text = false})

local function bindkeys(bufnr)
  local bindkey = require('../utils').bindkey
  local builtin = require('telescope.builtin');
  local buf = vim.lsp.buf

  bindkey('i', '<c-k>', buf.hover, {buffer = bufnr, desc = 'Displays hover information about the symbol under the cursor in a floating window'})
  bindkey('n', 'K', buf.hover, {buffer = bufnr, desc = 'Displays hover information about the symbol under the cursor in a floating window'})
  bindkey('n', 'gd', buf.definition, {buffer = bufnr, desc = 'Jumps to the definition of the symbol under the cursor'})
  bindkey('n', 'gD', buf.declaration, {buffer = bufnr, desc = 'Jumps to the declaration of the symbol under the cursor. Some servers does not implement this feature.'})
  bindkey('n', 'gi', buf.implementation, {buffer = bufnr, desc = 'Lists all the implementations for the symbol under the cursor in the quickfix window'})
  bindkey('n', 'go', buf.type_definition, {buffer = bufnr, desc = 'Jumps to the definition of the type of the symbol under the cursor'})
  bindkey('n', 'gr', buf.references, {buffer = bufnr, desc = 'Lists all the references to the symbol under the cursor in the quickfix window'})
  bindkey('n', 'gs', buf.signature_help, {buffer = bufnr, desc = 'Displays signature information about the symbol under the cursor in a floating window'})
  bindkey('n', '<leader>d', builtin.diagnostics, {buffer = bufnr, desc = 'Show diagnostics in a floating window'})
  bindkey('n', '<leader>rn', buf.rename, {buffer = bufnr, desc = 'Renames all references to the symbol under the cursor'})
  bindkey('n', '<leader>ga', buf.code_action, {buffer = bufnr, desc = 'Selects a code action available at the current cursor position'})
end

local function on_cursor_hold()
  vim.diagnostic.open_float(nil, {
    border = 'rounded',
    close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
    focus = false,
    focusable = false,
    prefix = ' ',
    scope = 'cursor',
    source = 'always',
  })
end

local function on_attach(_, bufnr)
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
  vim.api.nvim_create_autocmd('CursorHold,CursorHoldI', {buffer = bufnr, callback = on_cursor_hold})
  cmd('autocmd CursorHold,CursorHoldI * lua vim.diagnostic.open_float(nil, {focusable=false,source="always",prefix=" ",scope="cursor"})')
  bindkeys(bufnr)
end

local function on_attach_perl(_, bufnr)
  on_attach(_, bufnr)
  --- use('lsp_signature', function(sig)
  ---   sig.on_attach({bind = true, hint_enable = false}, bufnr)
  --- end)
end

local capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())
capabilities.textDocument.completion.completionItem.snippetSupport = true

local lspconfig = require('lspconfig')
lspconfig.bashls.setup({capabilities = capabilities, on_attach = on_attach})
lspconfig.cssls.setup({capabilities = capabilities, on_attach = on_attach})
lspconfig.eslint.setup({capabilities = capabilities, on_attach = on_attach})
lspconfig.html.setup({capabilities = capabilities, on_attach = on_attach})
lspconfig.perlpls.setup({capabilities = capabilities, on_attach = on_attach_perl});
lspconfig.svelte.setup({capabilities = capabilities, on_attach = on_attach})
lspconfig.tsserver.setup({capabilities = capabilities, on_attach = on_attach})

lspconfig.emmet_ls.setup({capabilities = capabilities, on_attach = on_attach,
  filetypes = {"css", "eruby", "html", "javascript", "javascriptreact", "less", "sass", "scss", "svelte", "pug", "typescriptreact", "vue"},
  init_options = {
    html = {
      options = {
        -- For possible options, see: https://github.com/emmetio/emmet/blob/master/src/config.ts#L79-L267
        ["bem.enabled"] = true,
      },
    },
  }
})

lspconfig.lua_ls.setup({capabilities = capabilities, on_attach = on_attach, settings = {
  Lua = {
    diagnostics = {globals = {'vim'}},
    runtime = {version = 'LuaJIT'},
    workspace = {library = vim.api.nvim_get_runtime_file("", true)},
    telemetry = {enable = false},
  },
}})

lspconfig.volar.setup({capabilities = capabilities, on_attach = on_attach, init_options = {
  typescript = {
    serverPath = '/opt/homebrew/lib/node_modules/typescript/lib/tsserverlibrary.js'
  }
}})

lspconfig.yamlls.setup({capabilities = capabilities, on_attach = on_attach, settings = {
  yaml = {
    keyOrdering = false,
  },
}})

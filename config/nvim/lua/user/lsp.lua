local use = require('utils').use;
local cmd = vim.cmd

local function on_cursor_hold()
  vim.diagnostic.open_float(nil, {
    border = 'rounded',
    close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
    focus = false,
    focusable = false,
    scope = 'cursor',
    source = 'always',
  })
end

local function on_attach(_, bufnr)
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
  vim.api.nvim_create_autocmd({'CursorHold', 'CursorHoldI'}, {buffer = bufnr, callback = on_cursor_hold})
  cmd('autocmd CursorHold,CursorHoldI * lua vim.diagnostic.open_float(nil, {focusable=false,source="always",prefix=" ",scope="cursor"})')

  local bindkey = require('../utils').bindkey
  local telescope = require('telescope.builtin');
  local buf = vim.lsp.buf

  bindkey('i', '<c-k>', buf.hover, {buffer = bufnr, desc = 'Displays hover information about the symbol under the cursor in a floating window'})
  bindkey('n', 'K', buf.hover, {buffer = bufnr, desc = 'Displays hover information about the symbol under the cursor in a floating window'})
  bindkey('n', 'gd', buf.definition, {buffer = bufnr, desc = 'Jumps to the definition of the symbol under the cursor'})
  bindkey('n', 'gD', buf.declaration, {buffer = bufnr, desc = 'Jumps to the declaration of the symbol under the cursor. Some servers does not implement this feature.'})
  bindkey('n', 'gi', buf.implementation, {buffer = bufnr, desc = 'Lists all the implementations for the symbol under the cursor in the quickfix window'})
  bindkey('n', 'go', buf.type_definition, {buffer = bufnr, desc = 'Jumps to the definition of the type of the symbol under the cursor'})
  bindkey('n', 'gr', buf.references, {buffer = bufnr, desc = 'Lists all the references to the symbol under the cursor in the quickfix window'})
  bindkey('n', 'gs', buf.signature_help, {buffer = bufnr, desc = 'Displays signature information about the symbol under the cursor in a floating window'})
  bindkey('n', '<leader>d', telescope.diagnostics, {buffer = bufnr, desc = 'Show diagnostics in a floating window'})
  bindkey('n', '<leader>rn', buf.rename, {buffer = bufnr, desc = 'Renames all references to the symbol under the cursor'})
  bindkey('n', '<leader>ga', buf.code_action, {buffer = bufnr, desc = 'Selects a code action available at the current cursor position'})
end

cmd('autocmd BufRead,BufNewFile *.jinja set filetype=html')
cmd('autocmd BufRead,BufNewFile *.tera set filetype=html')
cmd('autocmd BufRead,BufNewFile *.pcss set filetype=scss')
cmd('autocmd BufRead,BufNewFile *.css set filetype=scss')
cmd('autocmd BufRead,BufNewFile *.css.tera set filetype=scss')
cmd('autocmd BufRead,BufNewFile *.css.jinja set filetype=scss')

vim.diagnostic.config({
  float = {border = {"▔", "▔", "▔", " ", "▁", "▁", "▁", " "}},
  severity_sort = false,
  signs = true,
  underline = true,
  update_in_insert = false,
  virtual_text = false,
})

use('mason', function (mod)
  mod.setup({})

  use('mason-lspconfig', function (mod)
    mod.setup({
      automatic_installation = true,
      handlers = {
        function (server_name)
          require('lspconfig')[server_name].setup({capabilities = capabilities, on_attach = on_attach})
        end
      },
      ensure_installed = {
        'bashls',
        'css_variables',
        'emmet_ls',
        -- 'gopls',
        'html',
        'htmx',
        'jinja_lsp',
        'jsonls',
        'lua_ls',
        'nginx_language_server',
        'perlnavigator',
        'pylyzer',
        'rust_analyzer',
        'sqlls',
        'tsserver',
        'volar',
        'yamlls',
      },
    })
  end)
end)

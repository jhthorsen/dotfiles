-- vim.lsp.set_log_level('debug')
vim.o.updatetime = 250
vim.cmd [[autocmd! CursorHold,CursorHoldI * lua vim.diagnostic.open_float(nil, {focus=false})]]

local lsp_installer = require('nvim-lsp-installer')
local wantedServers = { 'bashls', 'cssls', 'html', 'jsonls', 'sqlls', 'svelte', 'tsserver', 'vuels', 'yamlls' }

for _, serverName in ipairs(wantedServers) do
  local server_is_found, server = lsp_installer.get_server(serverName)
  if not server_is_found or not server:is_installed() then
    print('Installing ' .. serverName)
    server:install()
  end
end

local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
local lsp_attached = function(client, bufnr)
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end
  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')
end

local util = require 'lspconfig.util'
local temp = function()
  return os.getenv('TEMP') or os.getenv('TMPDIR') or '/tmp'
end

lsp_installer.on_server_ready(function(server)
  server:setup({
    capabilities = capabilities,
    root_dir = util.root_pattern('.git') or temp,
    on_attach = lsp_attached,
    -- single_file_support = true,
    flags = {
      debounce_text_changes = 150,
    }
  })
end)

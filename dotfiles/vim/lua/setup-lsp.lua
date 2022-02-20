local lsp_installer = require("nvim-lsp-installer")
local wantedServers = { "bashls", "cssls", "html", "jsonls", "sqlls", "svelte", "tsserver", "vuels", "yamlls" }

for _, lsp in ipairs(wantedServers) do
  local server_is_found, server = lsp_installer.get_server(name)
  if server_is_found and not server:is_installed() then
    print("Installing " .. name)
    server:install()
  end
end

local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
local lsp_attached = function(client, bufnr)
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end
  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')
end

lsp_installer.on_server_ready(function(server)
  server:setup({
    capabilities = capabilities,
    on_attach = lsp_attached,
    flags = {
      debounce_text_changes = 150,
    }
  })
end)

local server_name = "perlpls";
local lspconfig = require "lspconfig"
local configs = require "lspconfig.configs"
configs[server_name] = {
  default_config = {
    filetypes = { "perl" },
    root_dir = lspconfig.util.root_pattern ".git",
  },
}

function perlpls_installer(server, callback, context)
  print("INSTALLED")
  callback(true)
end

local servers = require "nvim-lsp-installer.servers"
local server = require "nvim-lsp-installer.server"
servers.register(server.Server:new {
  name = server_name,
  installer = perlpls_installer,
  root_dir = server.get_server_root_path(server_name),
  default_options = {
    cmd = { "perl", "-MPLS::Server", "-e", "PLS::Server->new->run" }
  }
})

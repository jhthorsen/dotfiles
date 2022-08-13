local ssh_domains = require 'private_ssh_domains'
local wezterm = require 'wezterm'

for host, config in pairs(wezterm.enumerate_ssh_hosts()) do
  table.insert(ssh_domains, {
    name = host,
    remote_address = host,
  });
end

return ssh_domains;

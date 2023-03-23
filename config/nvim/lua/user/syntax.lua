local bindkey = require('../utils').bindkey
local use = require('../utils').use;

-- colors
use('colorizer', function (mod)
  local css = {css = true}
  local html = {RGB = true, RRGGBB = true}
  mod.setup({css = css, html = html, scss = css, svelte = html, vue = html})
end)

-- emmet
vim.g.user_emmet_install_global = 0
vim.g.user_emmet_leader_key = '<c-e>'
vim.cmd('autocmd FileType css,html,html.epl,scss,svelte,vue EmmetInstall')
vim.cmd('autocmd FileType css,scss setlocal commentstring=/*%s*/')

-- perl
vim.g.perl_fold = 0
vim.g.perl_include_pod = 1
vim.g.perl_no_extended_vars = 1
vim.g.perl_nofold_subs = 1
vim.g.perl_no_scope_in_variables = 1
vim.g.perl_sync_dist = 1

-- spelling
bindkey('i', '<c-s>', function() require('telescope.builtin').spell_suggest() end)
bindkey('n', '<leader>ss', ':set spell!<CR>')

-- surround
use('mini.surround', function (mod)
  mod.setup({
    mappings = {add = 'sa', delete = 'sd', find = 'sf', find_left = 'sF', replace = 'sr'},
  });
end)

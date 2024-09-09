local telescope_builtin = require('telescope.builtin')
local bindkey = require('../utils').bindkey
local use = require('../utils').use;

-- colors
use('colorizer', function (mod)
  local css = {css = true}
  local html = {RGB = true, RRGGBB = true}
  mod.setup({'*', css = css, html = html, scss = css, svelte = html, vue = html})
end)

-- emmet
vim.g.user_emmet_install_global = 0
vim.g.user_emmet_leader_key = '<c-e>'
vim.cmd('autocmd FileType css,scss setlocal commentstring=/*%s*/')

-- perl
vim.g.perl_fold = 0
vim.g.perl_include_pod = 1
vim.g.perl_no_extended_vars = 1
vim.g.perl_nofold_subs = 1
vim.g.perl_no_scope_in_variables = 1
vim.g.perl_sync_dist = 1

-- spelling
bindkey('n', '<leader>se', ':set spell spelllang=en<CR>', {desc = 'Set language to en'})
bindkey('n', '<leader>sn', ':set spell spelllang=nb<CR>', {desc = 'Set language to nb'})
bindkey('n', '<leader>sx', ':set nospell<CR>', {desc = 'Turn off spelling'})
bindkey('n', '<leader>sl', telescope_builtin.spell_suggest, {desc = 'Spell suggestions'});
bindkey('i', '<c-s>', telescope_builtin.spell_suggest, {desc = 'Spell suggestions'});

local bindkey = require('../utils').bindkey

-- emmet
vim.g.user_emmet_install_global = 0
vim.g.user_emmet_leader_key = '<c-e>'
vim.g.user_emmet_mode = 'i'
vim.cmd('autocmd FileType css,html,html.epl,svelte,vue EmmetInstall')
bindkey('i', '<leader>st', ':set spell!<CR>')

-- perl
vim.g.perl_fold = 0
vim.g.perl_include_pod = 1
vim.g.perl_no_extended_vars = 1
vim.g.perl_nofold_subs = 1
vim.g.perl_no_scope_in_variables = 1
vim.g.perl_sync_dist = 1

-- spelling
bindkey('i', '<c-s>', function() require('telescope.builtin').spell_suggest() end)
bindkey('n', '<leader>st', ':set spell!<CR>')

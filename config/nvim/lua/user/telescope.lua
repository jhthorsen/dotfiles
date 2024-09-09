local bindkey = require('../utils').bindkey
local builtin = require('telescope.builtin')
local telescope = require('telescope')

telescope.setup({
  defaults = {
    preview = false,
  },
  pickers = {
    buffers = {theme = 'ivy'},
    diagnostics = {theme = 'ivy'},
    git_files = {theme = 'ivy'},
    find_files = {theme = 'ivy'},
    live_grep = {theme = 'ivy'},
    keymaps = {theme = 'ivy'},
    oldfiles = {theme = 'ivy'},
    spell_suggest = {theme = 'ivy'},
  },
})

vim.cmd('autocmd BufReadPost * if line("\'\\"") > 0 && line("\'\\"") <= line("$") | exe "normal g\'\\"" | endif')

bindkey('n', '<c-p>', builtin.find_files, {desc = 'Find files'});
bindkey('n', '<leader>b', builtin.buffers, {desc = 'List buffers'});
bindkey('n', '<leader>fp', function() builtin.find_files({find_command = {'find-files-cached', '..'}}) end, {desc = 'Find files cached'})
bindkey('n', '<leader>fr', function() builtin.find_files({find_command = {'find-files-cached', '-r', '..'}}) end, {desc = 'Find files cached recursive'})
bindkey('n', '<leader>fg', builtin.live_grep, {desc = 'Grep for file contents'})
bindkey('n', '<leader>fo', builtin.oldfiles, {desc = 'Show file history'})
bindkey('n', '<leader>gf', builtin.git_files, {desc = 'List git files'})
bindkey('n', '<leader>tq', builtin.quickfix, {desc = 'Quickfix'})
bindkey('n', '<leader>hk', builtin.keymaps, {desc = 'Show keymaps'})

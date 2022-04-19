local telescope = require('telescope')
local utils = require('../utils')

telescope.setup({
  defaults = {
    preview = false
  },
  pickers = {
    buffers = {theme = 'ivy'},
    find_files = {theme = 'ivy'},
    live_grep = {theme = 'ivy'},
    spell_suggest = {theme = 'ivy'},
  },
})

utils.autocmd('jump_to_last_positon_in_file', {{'BufReadPost', '*',
  'if line("\'\\"") > 0 && line("\'\\"") <= line("$") | exe "normal g\'\\"" | endif'}})

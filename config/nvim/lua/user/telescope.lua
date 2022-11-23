local cmd = vim.cmd
local telescope = require('telescope')

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

cmd('autocmd BufReadPost * if line("\'\\"") > 0 && line("\'\\"") <= line("$") | exe "normal g\'\\"" | endif')

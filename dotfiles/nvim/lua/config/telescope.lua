local telescope = require('telescope')

telescope.setup({
  pickers = {
    buffers = {theme = 'ivy'},
    find_files = {theme = 'ivy'},
    live_grep = {theme = 'ivy'},
    spell_suggest = {theme = 'ivy'},
  },
})

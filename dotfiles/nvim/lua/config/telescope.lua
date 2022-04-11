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

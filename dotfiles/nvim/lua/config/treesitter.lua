require('nvim-treesitter.configs').setup({
  ensure_installed = {'perl'},
  context_commentstring = {enable = true},
  highlight = {enable = true},
  indent = {enable = true},
})

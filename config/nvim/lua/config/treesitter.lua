require('nvim-treesitter.configs').setup({
  ensure_installed = {'bash', 'html', 'javascript', 'json', 'lua', 'perl', 'scss', 'svelte', 'typescript', 'vue'},
  context_commentstring = {enable = true},
  highlight = {enable = true},
  indent = {enable = true},
})

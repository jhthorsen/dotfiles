require('nvim-treesitter.configs').setup({
  ensure_installed = {'bash', 'html', 'javascript', 'json', 'lua', 'scss', 'svelte', 'typescript', 'vue'},
  auto_install = true,
  sync_install = false,
  highlight = {
    disable = {'perl'},
    enable = true,
  },
  indent = {
    enable = false,
  },
})

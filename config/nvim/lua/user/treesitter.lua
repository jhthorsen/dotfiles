require('nvim-treesitter.configs').setup({
  ensure_installed = {'bash', 'html', 'htmldjango', 'javascript', 'json', 'lua', 'rust', 'scss', 'svelte', 'typescript', 'vue', 'yaml'},
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

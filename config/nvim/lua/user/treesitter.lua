require('nvim-treesitter.configs').setup({
  ensure_installed = {'bash', 'html', 'javascript', 'json', 'lua', 'scss', 'svelte', 'typescript', 'vue'},
  -- context_commentstring = {enable = true},
  highlight = {
    -- additional_vim_regex_highlighting = true,
    disable = {'perl'},
    enable = true,
  },
  indent = {
    enable = false,
  },
})

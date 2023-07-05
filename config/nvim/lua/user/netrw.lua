local bindkey = require('../utils').bindkey

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require('nvim-tree').setup({
  filters = {
    dotfiles = false,
  },
  view = {
    width = 30,
  },
  on_attach = function(bufnr)
    local api = require('nvim-tree.api')
    api.config.mappings.default_on_attach(bufnr)
  end
})

local api = require('nvim-tree.api')
bindkey('n', '<leader>e', function() api.tree.toggle({find_file = true}) end, {desc = 'Toggle nvim tree'})

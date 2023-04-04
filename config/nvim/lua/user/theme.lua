local use = require('utils').use;

vim.g.spell_under = 'kanagawa'
use('kanagawa', function(kanagawa)
  kanagawa.setup({
    dimInactive = true,
    transparent = true,
  })
end)

vim.api.nvim_exec([[
  syntax match NonASCII "[^\x00-\x7F]"
  highlight NonASCII ctermbg=red guibg=red
  highlight NonText ctermbg=none guibg=none guifg=250
  highlight Normal ctermbg=none guibg=none guifg=252
]], false)

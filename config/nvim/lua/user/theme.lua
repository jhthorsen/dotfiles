local use = require('utils').use;

vim.g.spell_under = 'fluoromachine'

use('fluoromachine', function(fm)
  fm.setup({
    glow = false,
    theme = 'retrowave',
    brightness = 0.9,
    transparent = true,
    overrides = {
      ['@comment'] = {fg = '#5869d2'},
    },
  })
end)

vim.api.nvim_exec([[
  syntax match NonASCII "[^\x00-\x7F]"
  highlight NonASCII ctermbg=red guibg=red
  highlight NonText ctermbg=none guibg=none guifg=250
  highlight Normal ctermbg=none guibg=none guifg=252
]], false)

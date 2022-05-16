vim.o.background = 'dark'
vim.g.gruvbox_contrast_dark = 'hard'
vim.o.spell = true
vim.g.spell_under = 'gruvbox';

vim.api.nvim_exec([[
  syntax match NonASCII "[^\x00-\x7F]"

  highlight Comment ctermbg=darkgray guibg=darkgray ctermfg=black guifg=black
  highlight NonASCII ctermbg=red guibg=red
  highlight NonText ctermbg=none guibg=none guifg=250
  highlight Normal ctermbg=none guibg=none guifg=252
]], false)

local feline = require('feline')
feline.add_preset('custom', require('feline.presets.custom'))
feline.setup({preset = 'custom'})

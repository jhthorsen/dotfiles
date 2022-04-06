vim.g.gruvbox_italic = 1
vim.o.background = 'dark'

vim.api.nvim_exec([[
  colorscheme gruvbox
  syntax match NonASCII "[^\x00-\x7F]"

  highlight Comment ctermbg=darkgray guibg=darkgray ctermfg=black guifg=black
  highlight NonText ctermbg=none guibg=none guifg=250
  highlight Normal ctermbg=none guibg=none guifg=252
  highlight NonASCII ctermbg=red guibg=red
]], false)

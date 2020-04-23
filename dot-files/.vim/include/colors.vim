syntax on

set background=dark
let g:gruvbox_italic=1
colorscheme gruvbox
highlight Normal ctermbg=none

highlight NonASCII ctermbg=red guibg=red
syntax match NonASCII "[^\x00-\x7F]"

let g:lightline = {
  \ 'active': {
  \   'left': [ [ 'mode', 'paste' ],
  \             [ 'readonly', 'filename', 'modified' ] ],
  \   'right': [ [ 'lineinfo' ],
  \              [ 'percent' ],
  \              [ 'fileformat', 'fileencoding', 'filetype' ] ]
  \ },
  \ 'inactive': {
  \ },
  \ 'tabline': {
  \   'left': [ [ 'tabs' ] ],
  \   'right': [ [ ] ]
  \ },
  \ 'component': {
  \   'charvaluehex': '0x%B'
  \ },
  \ 'component_function': {
  \   'filename': 'LightlineFilename'
  \ }
  \ }

function! LightlineFilename()
  if &buftype ==# 'terminal'
    return expand('%:p')
  elseif expand('%:t') !=# ''
    return expand('%')
  else
    return '[No Name]'
  endif
endfunction

syntax on
set background=dark
set termguicolors
let g:gruvbox_italic=1
let g:lightline.colorscheme = 'gruvboxdark'
colorscheme gruvbox

highlight Comment ctermbg=darkgray guibg=darkgray ctermfg=black guifg=black
highlight NonText ctermbg=none guibg=none guifg=250
highlight Normal ctermbg=none guibg=none guifg=252

highlight NonASCII ctermbg=red guibg=red
syntax match NonASCII "[^\x00-\x7F]"

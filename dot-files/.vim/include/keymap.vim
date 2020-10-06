let mapleader = "\<Space>"

" terminal navigation
let termKeys = [
  \ {'key': '<C-h>', 'to': '<C-w>h'},
  \ {'key': '<C-j>', 'to': '<C-w>j'},
  \ {'key': '<C-k>', 'to': '<C-w>k'},
  \ {'key': '<C-l>', 'to': '<C-w>l'},
  \ {'key': '<C-j>', 'to': ':tabprevious<CR>'},
  \ {'key': '<C-h>', 'to': ':tabprevious<CR>'},
  \ {'key': '<C-k>', 'to': ':tabnext<CR>'},
  \ {'key': '<C-l>', 'to': ':tabnext<CR>'},
\]

if has("nvim")
  for item in termKeys
    exe 'nnoremap ' . item.key . ' ' . item.to
    exe 'inoremap ' . item.key . ' <C-\><C-N>' . item.to
    exe 'tnoremap ' . item.key . ' <C-\><C-N>' . item.to
  endfor
endif

" copy/paste to clipboard
set clipboard=unnamed
vmap <C-c> :w !snipclip -i<CR><CR>
vmap <C-v> c<ESC>:set paste<CR>:r !snipclip -o<CR>:set nopaste<CR>
imap <C-v> <ESC>:set paste<CR>:r !snipclip -o<CR>:set nopaste<CR>a

" utilites
noremap ,t :!column -t<CR>
inoremap ,dd warn Mojo::Util::dumper();<C-o>h

" ctrl+f and ctrl+b moves cursor half screen up/down
noremap <C-f> <C-d>
noremap <C-b> <C-u>

" edit file in new tab
noremap ,e :tabedit <C-R>=expand("%:h")<CR>

" gnome-terminal/something puts weird characters into my files
noremap ,f :%s/\%xa0/ /g<CR>

" alt+e reloads the current file
noremap é :e!<Enter>

" https://stackoverflow.com/questions/4064651/what-is-the-best-way-to-do-smooth-scrolling-in-vim
" https://github.com/Kazark/vim-SimpleSmoothScroll
map <ScrollWheelUp> :call SmoothScroll(1)<Enter>
map <ScrollWheelDowsn> :call SmoothScroll(0)<Enter>

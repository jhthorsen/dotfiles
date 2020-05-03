let mapleader = "\<Space>"

" copy/paste to clipboard
vmap <C-c> "+yi
vmap <C-x> "+c
vmap <C-v> c<ESC>"+p
imap <C-v> <ESC>"+pa

" utilites
noremap ,t :!column -t<CR>
inoremap ,dd warn Mojo::Util::dumper();<C-o>h

" ctrl+f and ctrl+b moves cursor half screen up/down
noremap <C-f> <C-d>
noremap <C-b> <C-u>

" ctrl+h moves cursor to center of screen
noremap <C-h> M

" ctrl+j and ctrl+k changes to previous/next tab
" ctrl+m might be an alias for C-j
noremap <C-j> :tabprevious<CR>
noremap <C-m> :tabprevious<CR>
noremap <C-k> :tabnext<CR>
noremap ,e :tabedit <C-R>=expand("%:h")<CR>

" for some reason <CR> seems to be mapped to :tabprevious (?)
unmap <CR>

" gnome-terminal/something puts weird characters into my files
noremap ,f :%s/\%xa0/ /g<CR>

" alt+j and alt+k scrolls the window
noremap √ <C-e>
noremap ª <C-y>

" alt+e reloads the current file
noremap é :e!<Enter>

" https://stackoverflow.com/questions/4064651/what-is-the-best-way-to-do-smooth-scrolling-in-vim
" https://github.com/Kazark/vim-SimpleSmoothScroll
map <ScrollWheelUp> :call SmoothScroll(1)<Enter>
map <ScrollWheelDowsn> :call SmoothScroll(0)<Enter>

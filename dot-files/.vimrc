" !perl -MMojo::Util=url_unescape -nle'print url_unescape $_'

" vundle start
set shell=zsh
set nocompatible
filetype off
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'
Plugin 'vim-perl/vim-perl'
" Plugin 'altercation/vim-colors-solarized'
Plugin 'cakebaker/scss-syntax.vim'
Plugin 'conradirwin/vim-bracketed-paste'
Plugin 'ap/vim-css-color'
Plugin 'gabrielelana/vim-markdown'
Plugin 'hail2u/vim-css3-syntax'
Plugin 'mattn/emmet-vim'
Plugin 'othree/html5.vim'
Plugin 'pangloss/vim-javascript'
Plugin 'posva/vim-vue'
Plugin 'skywind3000/asyncrun.vim'
Plugin 'terryma/vim-multiple-cursors'
Plugin 'yko/mojo.vim'
Plugin 'evanleck/vim-svelte'

call vundle#end()
filetype plugin indent on
" vundle end

set autoindent
" set autowrite
set backspace=indent,eol,start " more powerful backspacing
set complete=.,w,b,u,t,kspell " skip grep after functions in all perl libraries
set encoding=utf-8
set expandtab
set history=100
set laststatus=2
set nobackup
set nofoldenable
set nostartofline
set noswapfile
set nowrap
" set relativenumber
set shiftround
set shiftwidth=2
set showcmd
set smartindent
set softtabstop=2
set statusline=%f\ %{strlen(&fenc)?&fenc:'none'},%{&ff},%{&ft}\ (%B)\ %h%m%r%=%c,%l/%L\ %P"
set tabstop=8
set wildignore+=*/.git/*,*/node_modules/*,*/.DS_Store,*/vendor,*.min.*,*.png,*.jpg

" tab completion
set wildmode=list:longest
set wildignorecase
" set wildmenu
noremap <C-u> 20k
noremap <C-d> 20j
noremap <C-h> zz

" colors
syntax on
" let g:solarized_termtrans = 1
" let g:solarized_bold = 1
" let g:solarized_italic = 0
" set background=dark
set background=dark
" set t_Co=16
" colorscheme solarized
highlight clear LineNr

" netrw
" let g:netrw_write_AsyncRun = 1

" w0rp/ale config
" let g:ale_linters = {'perl': ['perl']}
" let g:ale_sign_warning = '⊙'
" let g:ale_sign_error = '⊘'
" let g:ale_yaml_yamllint_options = '-d "{extends: default, rules: {line-length: disable, indentation: { indent-sequences: whatever}}}"'

" plugins
" let g:multi_cursor_exit_from_insert_mode = 0
" let g:multi_cursor_exit_from_visual_mode = 0
" let g:multi_cursor_next_key = '<C-d>'
" let g:perl_podjumper_key = ',p'
let g:multi_cursor_start_key  = '<C-d>'
let g:multi_cursor_next_key = '<C-d>'

" emmet
let g:user_emmet_expandabbr_key = '<C-e>'
let g:user_emmet_expandword_key = '<C-E>'
let g:user_emmet_update_tag = '<C-y>u'
let g:user_emmet_balancetaginward_key = '<C-y>d'
let g:user_emmet_balancetagoutward_key = '<C-y>D'
let g:user_emmet_next_key = '<C-y>n'
let g:user_emmet_prev_key = '<C-y>N'
let g:user_emmet_imagesize_key = '<C-y>i'
let g:user_emmet_togglecomment_key = '<C-y>/'
let g:user_emmet_splitjointag_key = '<C-y>j'
let g:user_emmet_removetag_key = '<C-y>k'
let g:user_emmet_anchorizeurl_key = '<C-y>a'
let g:user_emmet_anchorizesummary_key = '<C-y>A'
let g:user_emmet_mergelines_key = '<C-y>m'
let g:user_emmet_codepretty_key = '<C-y>c'
let g:user_emmet_complete_tag = 1
let g:user_emmet_mode = 'i'

" tabs
" C-m might be an alias for C-j
map <C-j> :tabprevious<CR>
map <C-m> :tabprevious<CR>
map <C-k> :tabnext<CR>
map ,e :tabedit <C-R>=expand("%:h")<CR>

" gnome-terminal/something puts weird characters into my files
map ,f :%s/\%xa0/ /g<CR>

" autocmd BufEnter,TabEnter,WinEnter * syn match ErrorMsg /[^\x00-\x7F]/
" autocmd BufEnter,TabEnter,WinEnter * syn match ErrorMsg /\s\+$/
" syntax match nonascii "[^\x00-\x7F]"
" highlight nonascii guibg=red ctermbg=red

" using two spaces now in RG:: code
" autocmd BufRead,BufNewFile /Users/jhthorsen/git/_rg/* setlocal softtabstop=4 shiftwidth=4

" search for highlighted text
" map ,/ "ay/<C-R>a<CR>

" change formatting
" map ,html :set filetype=html<CR>
autocmd! BufRead,BufNewFile *.sass set filetype=sass
autocmd! BufRead,BufNewFile *.tt set filetype=tt2
autocmd! BufRead,BufNewFile *.tt2 set filetype=tt2

autocmd! FileType perl setlocal foldmethod=manual
let perl_fold=0

hi! MatchParen cterm=NONE,bold gui=NONE,bold guibg=#3e3835 guifg=NONE

" autocmd VimEnter * silent !echo -ne "\033]1337;PushKeyLabels\a"
" autocmd VimEnter * silent !echo -ne "\033]1337;SetKeyLabel=F1=Save & Quit\a"
" autocmd VimEnter * map <F1> :wq<CR>
" autocmd VimLeave * silent !echo -ne "\033]1337;PopKeyLabels\a"

" nnoremap / :M/
" nnoremap ,/ /

" fzf
set rtp+=/usr/local/opt/fzf
let g:fzf_layout = { 'down': '~30%' }
map <C-p> :FZF --info=inline<CR>

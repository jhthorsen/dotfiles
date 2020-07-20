call plug#begin('~/.vim/plugged')

Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'junegunn/vim-easy-align' " https://github.com/junegunn/vim-easy-align
Plug 'vim-perl/vim-perl'
Plug 'cakebaker/scss-syntax.vim'
Plug 'conradirwin/vim-bracketed-paste'
Plug 'ap/vim-css-color'
Plug 'gabrielelana/vim-markdown'
Plug 'hail2u/vim-css3-syntax'
Plug 'kazark/vim-SimpleSmoothScroll'
Plug 'mattn/emmet-vim'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'othree/html5.vim'
Plug 'pangloss/vim-javascript'
Plug 'posva/vim-vue'
Plug 'seletskiy/vim-nunu'
Plug 'skywind3000/asyncrun.vim'
Plug 'terryma/vim-multiple-cursors'
Plug 'yko/mojo.vim'
Plug 'morhetz/gruvbox'
Plug 'evanleck/vim-svelte'
Plug 'jeetsukumaran/vim-buffergator'

call plug#end()

let g:DOT_FILES_PATH=fnamemodify(resolve(expand("<sfile>:p")), ":h")

set autoindent
set autoread
set backspace=indent,eol,start
set complete=.,w,b,u,t,kspell
set encoding=utf-8
set expandtab
set history=100
set laststatus=2
set mouse=i
set nocompatible
set nofoldenable
set noincsearch
set nostartofline
set noswapfile
set nowrap
set shell=zsh
set shiftround
set shiftwidth=2
set showcmd
set smartcase
set smartindent
set softtabstop=2
set statusline=%f\ %{strlen(&fenc)?&fenc:'none'},%{&ff},%{&ft}\ (%B)\ %h%m%r%=%c,%l/%L\ %P"
set tabstop=8
set wildignore+=*/.git/*,*/node_modules/*,*/.DS_Store,*/vendor,*.min.*,*.png,*.jpg
set wildignorecase
set wildmode=list:longest

" required by neoclide/coc.nvim
set cmdheight=2
set hidden
set nobackup
set nowritebackup
set shortmess+=c
set signcolumn=yes
set updatetime=250

" Misc config
execute "source " . g:DOT_FILES_PATH . "/.vim/include/ft.vim"
execute "source " . g:DOT_FILES_PATH . "/.vim/include/keymap.vim"
execute "source " . g:DOT_FILES_PATH . "/.vim/include/colors.vim"
execute "source " . g:DOT_FILES_PATH . "/.vim/include/fzf.vim"

" Utilities
execute "source " . g:DOT_FILES_PATH . "/.vim/include/lastpos.vim"
execute "source " . g:DOT_FILES_PATH . "/.vim/include/mkdir.vim"
execute "source " . g:DOT_FILES_PATH . "/.vim/include/spelling.vim"

" Plugin config
execute "source " . g:DOT_FILES_PATH . "/.vim/include/coc.vim"
execute "source " . g:DOT_FILES_PATH . "/.vim/include/emmet.vim"
execute "source " . g:DOT_FILES_PATH . "/.vim/include/multiple-cursors.vim"

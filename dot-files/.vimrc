call plug#begin('~/.vim/plugged')

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

call plug#end()

set shell=zsh
set nocompatible
set autoindent
" set autowrite
set backspace=indent,eol,start " more powerful backspacing
set complete=.,w,b,u,t,kspell " skip grep after functions in all perl libraries
set encoding=utf-8
set expandtab
set history=100
set laststatus=2
set nofoldenable
set noincsearch
set nostartofline
set noswapfile
set nowrap
" set relativenumber
" set number
set shiftround
set shiftwidth=2
set showcmd
set smartcase
set smartindent
set softtabstop=2
set statusline=%f\ %{strlen(&fenc)?&fenc:'none'},%{&ff},%{&ft}\ (%B)\ %h%m%r%=%c,%l/%L\ %P"
set tabstop=8
set wildignore+=*/.git/*,*/node_modules/*,*/.DS_Store,*/vendor,*.min.*,*.png,*.jpg

set wildmode=list:longest
set wildignorecase

" movement
noremap <C-f> <C-d>
noremap <C-b> <C-u>

noremap <C-h> M
noremap √ <C-e>h " alt+j
noremap ª <C-y>h " alt+k

" https://stackoverflow.com/questions/4064651/what-is-the-best-way-to-do-smooth-scrolling-in-vim
" https://github.com/Kazark/vim-SimpleSmoothScroll
set mouse=i
map <ScrollWheelUp> :call SmoothScroll(1)<Enter>
map <ScrollWheelDown> :call SmoothScroll(0)<Enter>

" noremap ¬ <C-e> " alt+shift+j
" noremap º <C-y> " alt+shift+k
" inoremap ª <Esc>:m .+1<CR>==gi
" inoremap º <Esc>:m .-2<CR>==gi
" vnoremap ª :m '>+1<CR>gv=gv
" vnoremap º :m '<-2<CR>gv=gv

" colors
syntax on
" colorscheme pablo
set background=dark
let g:gruvbox_italic=1
colorscheme gruvbox
highlight nonascii guibg=red ctermbg=red
highlight Normal ctermbg=none
" highlight Comment ctermbg=gray ctermfg=none
" highlight LineNr ctermbg=none ctermfg=darkgrey
" highlight StatusLine ctermbg=darkblue ctermfg=white
" highlight SignColumn ctermbg=none

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

" coc
set hidden
set nobackup
set nowritebackup
set cmdheight=2
set updatetime=250
set shortmess+=c
set signcolumn=yes

inoremap <silent><expr> <TAB> pumvisible() ? "\<C-n>" : <SID>check_back_space() ? "\<TAB>" : coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

inoremap <silent><expr> <c-space> coc#refresh()

" Use <cr> to confirm completion, `<C-g>u` means break undo chain at current
" position. Coc only does snippet and additional edit on confirm.
if exists('*complete_info')
  inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"
else
  imap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
endif

" Use `[g` and `]g` to navigate diagnostics
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocActionAsync('doHover')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)

" Formatting selected code.
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocActionAsync('formatSelected')
  " Update signature help on jump placeholder.
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Applying codeAction to the selected region.
" Example: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap keys for applying codeAction to the current line.
nmap <leader>ac  <Plug>(coc-codeaction)
" Apply AutoFix to problem on the current line.
nmap <leader>qf  <Plug>(coc-fix-current)

" Introduce function text object
" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
xmap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap if <Plug>(coc-funcobj-i)
omap af <Plug>(coc-funcobj-a)

" Use <TAB> for selections ranges.
" NOTE: Requires 'textDocument/selectionRange' support from the language server.
" coc-tsserver, coc-python are the examples of servers that support it.
nmap <silent> <TAB> <Plug>(coc-range-select)
xmap <silent> <TAB> <Plug>(coc-range-select)

" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocActionAsync('format')

" Add `:Fold` command to fold current buffer.
command! -nargs=? Fold :call     CocActionAsync('fold', <f-args>)

" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR   :call     CocActionAsync('runCommand', 'editor.action.organizeImport')

" Add (Neo)Vim's native statusline support.
" NOTE: Please see `:h coc-status` for integrations with external plugins that
" provide custom statusline: lightline.vim, vim-airline.
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" Mappings using CoCList:
" Show all diagnostics.
nnoremap <silent> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions.
nnoremap <silent> <space>e  :<C-u>CocList extensions<cr>
" Show commands.
nnoremap <silent> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document.
nnoremap <silent> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols.
nnoremap <silent> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list.
nnoremap <silent> <space>p  :<C-u>CocListResume<CR>

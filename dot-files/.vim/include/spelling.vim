map ,s :call ActivateSpelling()<CR>
imap <C-L> <C-R>=SuperCleverSpeller()<CR>

let s:languages = [ "en_us", "nb" ] " http://ftp.vim.org/vim/runtime/spell/
let s:language_index = 0

function! ActivateSpelling()
  if(s:language_index == len(s:languages))
    let s:language_index = 0
    syntax on
    setlocal nospell
    echo "spelling=off"
  else
    let &l:spelllang = s:languages[s:language_index]
    let s:language_index = s:language_index + 1
    syntax off
    setlocal spell
    highlight clear SpellBad
    highlight SpellBad term=standout ctermfg=1 term=underline cterm=underline
    highlight clear SpellCap
    highlight SpellCap term=underline cterm=underline
    highlight clear SpellRare
    highlight SpellRare term=underline cterm=underline
    highlight clear SpellLocal
    highlight SpellLocal term=underline cterm=underline
    echo "spelling=" . &l:spelllang
  endif

  return ""
endfunction

function! SuperCleverSpeller()
  if pumvisible()             " menu visible
    call feedkeys("\<C-N>")
  else
    call feedkeys("\<C-X>s")
  endif
  
  return ""
endfunction

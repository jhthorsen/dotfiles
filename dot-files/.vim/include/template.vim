autocmd Bufenter *.* call LoadTemplate()

map ,m :execute "normal i" . ModuleName()

function! LoadTemplate()
  let a:bytes = line2byte(line('$') + 1)
  if a:bytes >= 3
    return
  endif

  let a:ext = expand("%:e") | " get extension
  let a:filename = expand("%:p") | " get filename

  if a:filename =~ '/_posts/'
    read $HOME/Templates/post.markdown
    normal ggdd
  elseif a:ext == "html"
    read $HOME/Templates/index.html
    normal ggdd
  elseif a:ext == "css"
    read $HOME/Templates/stylesheet.css
    normal ggdd
  elseif a:ext == "pm"
    let a:name = ModuleName()
    read $HOME/Templates/Module.pm
    execute ":%s/Unknown::Module/" . a:name . "/g"
    normal ggdd
  elseif a:ext == "t"
    read $HOME/Templates/perl.t
    normal ggdd
  elseif a:ext == "pl"
    read $HOME/Templates/script.pl
    normal ggdd
  endif
endfunction

function! ModuleName()
  let a:file = expand("%:p")
  if a:file =~ 'lib/.*\.pm'
    let a:location = split(a:file, "lib/")
    let a:name = len(a:location) == 2 ? a:location[1] : a:location[0]
    let a:name = substitute(a:name, '/', '::', 'g')
    let a:name = substitute(a:name, '.pm', '', '')
    return a:name
  else
    return "Unknown::Module"
  endif
endfunction 

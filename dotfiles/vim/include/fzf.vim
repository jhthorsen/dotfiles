let g:fzf_layout = { 'down': '~30%' }
map <C-p> :FZF --info=inline<CR>

function! FzfEditScp(lines)
  if len(a:lines) < 2
    return
  endif

  if a:lines[0] == 'ctrl-t'
    exec 'tabedit scp://' . $SSHJ_TARGET_HOST . '/' . a:lines[1]
  else
    exec 'edit scp://' . $SSHJ_TARGET_HOST . '/' . a:lines[1]
  endif
endfunction

if $SSHJ_CACHE_FILE =~ '/'
  unmap <C-P>
  map <C-p> :call fzf#run({'down': '~30%', 'options': ' --expect=ctrl-t,enter', 'source': 'cat ' . $SSHJ_CACHE_FILE, 'sink*': funcref('FzfEditScp')})<CR>
endif

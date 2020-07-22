let g:fzf_layout = { 'down': '~30%' }
map <C-p> :FZF --info=inline<CR>

function! FzfEditScp(file)
  exec 'tabedit scp://' . $SSHJ_TARGET_HOST . '/' . a:file
endfunction

if $SSHJ_CACHE_FILE =~ '/'
  unmap <C-p>
  map <C-p> :call fzf#run({'source': 'cat ' . $SSHJ_CACHE_FILE, 'sink': funcref('FzfEditScp')})<CR>
endif

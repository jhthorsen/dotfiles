lua <<EOF
require'fzf-lua'.setup {
  buffers = {
    previewer = false,
  },
  files = {
    previewer = false,
  },
  winopts = {
    win_height = 0.40,
    win_width = 0.85,
    win_row = 0.85,
  },
}
EOF

nnoremap <Leader>b <cmd>lua require('fzf-lua').buffers()<CR>
nnoremap <Leader>g <cmd>lua require('fzf-lua').grep()<CR>
nnoremap <c-P> <cmd>lua require('fzf-lua').files()<CR>

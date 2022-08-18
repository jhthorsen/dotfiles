local bindkey = vim.keymap.set
local cmd = vim.cmd

vim.o.clipboard = 'unnamed'
bindkey('v', '<c-c>', ':w !snipclip -i<CR><CR>')
bindkey('i', '<c-v>', '<ESC>:set paste<CR>:r !snipclip -o<CR>:set nopaste<CR>a')

-- 0dd, 0de, ... does not cut - it just deletes
bindkey('n', '0d', '"_d')
bindkey('v', '0d', '"_d')

cmd('autocmd TextYankPost if v:event.operator ==# "y" | call system("snipclip -i", @0) | endif')

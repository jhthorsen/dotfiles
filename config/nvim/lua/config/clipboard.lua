local utils = require('../utils')
local set_keymap = vim.api.nvim_set_keymap

vim.o.clipboard = 'unnamed'
utils.autocmd('clipboard', {{'TextYankPost', 'if v:event.operator ==# "y" | call system("snipclip -i", @0) | endif'}});
set_keymap('v', '<c-c>', ':w !snipclip -i<CR><CR>', {})
set_keymap('i', '<c-v>', '<ESC>:set paste<CR>:r !snipclip -o<CR>:set nopaste<CR>a', {})

-- 0dd, 0de, ... does not cut - it just deletes
set_keymap('n', '0d', '"_d', {noremap = true})
set_keymap('v', '0d', '"_d', {noremap = true})

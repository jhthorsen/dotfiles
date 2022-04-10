local utils = require('../utils')

vim.o.clipboard = 'unnamed'
vim.api.nvim_set_keymap('v', '<c-v>', ':w !snipclip -i<CR><CR>', {})
vim.api.nvim_set_keymap('v', '<c-v>', 'c<ESC>:set paste<CR>:r !snipclip -o<CR>:set nopaste<CR>', {})
vim.api.nvim_set_keymap('i', '<c-v>', '<ESC>:set paste<CR>:r !snipclip -o<CR>:set nopaste<CR>a', {})

local utils = require('../utils')

vim.g.mapleader = ' '

-- buffers and files
vim.api.nvim_set_keymap('n', '<leader>b', '<cmd>lua require("telescope.builtin").buffers()<CR>', {noremap = true})
vim.api.nvim_set_keymap('n', '<leader>g', '<cmd>lua require("telescope.builtin").live_grep()<CR>', {noremap = true})
vim.api.nvim_set_keymap('n', '<leader>eol', ':set binary noeol<CR>:w<CR>', {noremap = true})
vim.api.nvim_set_keymap('n', '<c-p>', '<cmd>lua require("telescope.builtin").find_files()<CR>', {noremap = true})
vim.api.nvim_set_keymap('n', ',e', ':tabedit <C-R>=expand("%:h")<CR>', {noremap = true})

-- netrw
vim.api.nvim_set_keymap('n', '<leader>e', ':Lexplore<CR>', {noremap = true})
vim.api.nvim_set_keymap('n', '<leader>f', ':silent Lexplore %:p:h<CR>', {noremap = true})
utils.autocmd('netrw', {
  {'filetype', 'netrw', 'nmap <buffer> e <CR>:Lexplore<CR>'},
  {'filetype', 'netrw', 'nmap <buffer> q :Lexplore<CR>'},
  {'filetype', 'netrw', 'nmap <buffer> . gh<CR>'},
  {'filetype', 'netrw', 'nmap <buffer> <leader><tab> mu'},
  {'filetype', 'netrw', 'nmap <buffer> <s-tab> mF'},
  {'filetype', 'netrw', 'nmap <buffer> <tab> mf'},
})

-- search
vim.api.nvim_set_keymap('n', '\'', '/', {noremap = true})
vim.api.nvim_set_keymap('n', '<c-s>', ':%s!', {noremap = true})

-- signcolumn
vim.api.nvim_set_keymap('n', '<leader>cd', ':setlocal norelativenumber nonumber signcolumn=no<CR>', {noremap = true})
vim.api.nvim_set_keymap('n', '<leader>ce', ':setlocal relativenumber number signcolumn=yes<CR>', {noremap = true})

-- spelling
vim.api.nvim_set_keymap('i', '<c-s>', '<cmd>lua require("telescope.builtin").spell_suggest()<CR>', {noremap = true})
vim.api.nvim_set_keymap('n', '<leader>se', ':syntax off<CR>:set spell<CR>', {noremap = true})
vim.api.nvim_set_keymap('n', '<leader>sd', ':syntax on<CR>:set spell<CR>', {noremap = true})

-- tab
vim.api.nvim_set_keymap('n', '<c-j>', ':tabprev<CR>', {noremap = true})
vim.api.nvim_set_keymap('n', '<c-k>', ':tabnext<CR>', {noremap = true})

-- visual-multi
vim.api.nvim_set_keymap('n', '<c-d>', '<c-n>', {noremap = false})
vim.api.nvim_set_keymap('v', '<c-d>', '<c-n>', {noremap = false})

-- window
vim.api.nvim_set_keymap('n', '<leader>h', '<c-w><c-h>', {noremap = true})
vim.api.nvim_set_keymap('n', '<leader>j', '<c-w><c-j>', {noremap = true})
vim.api.nvim_set_keymap('n', '<leader>k', '<c-w><c-k>', {noremap = true})
vim.api.nvim_set_keymap('n', '<leader>l', '<c-w><c-l>', {noremap = true})
vim.api.nvim_set_keymap('n', 'sp', ':sp<CR>', {noremap = true})
vim.api.nvim_set_keymap('n', 'vs', ':vs<CR>', {noremap = true})

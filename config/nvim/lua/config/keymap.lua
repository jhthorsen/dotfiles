local bindkey = vim.keymap.set

vim.g.mapleader = ' '

--- NTBBloodbath/color-converter.nvim
bindkey('n', '<leader>hsl', function() require('color-converter').to_hsl() end)
bindkey('n', '<leader>rgb', function() require('color-converter').to_rgb() end)

-- buffers and files
bindkey('n', '<leader>g', function() require('telescope.builtin').live_grep() end)
bindkey('n', '<leader>b', function() require('telescope.builtin').buffers() end)
bindkey('n', '<c-p>', function() require('telescope.builtin').find_files() end)
bindkey('n', '<c-j>', ':bprevious<CR>')
bindkey('n', '<c-k>', ':bnext<CR>')
bindkey('n', '<c-t>', ':enew<CR>')
bindkey('n', ',e', ':e <C-R>=expand("%:h")<CR>')

-- search
bindkey('n', '\'', '/')
bindkey('n', '<c-s>', ':%s!')

-- signcolumn
bindkey('n', '<leader>cd', ':setlocal norelativenumber nonumber signcolumn=no<CR>')
bindkey('n', '<leader>ce', ':setlocal relativenumber number signcolumn=yes<CR>')

-- spelling
bindkey('i', '<c-s>', function() require('telescope.builtin').spell_suggest() end)
bindkey('n', '<leader>st', ':set spell!<CR>')

-- visual-multi
bindkey('n', '<c-d>', '<c-n>', {remap = true})
bindkey('v', '<c-d>', '<c-n>', {remap = true})

-- window
bindkey('n', '<leader>h', '<c-w><c-h>')
bindkey('n', '<leader>j', '<c-w><c-j>')
bindkey('n', '<leader>k', '<c-w><c-k>')
bindkey('n', '<leader>l', '<c-w><c-l>')
bindkey('n', 'sp', ':sp<CR>')
bindkey('n', 'vs', ':vs<CR>')

local bindkey = require('../utils').bindkey

vim.o.timeoutlen = 300
vim.g.mapleader = ' '

--- NTBBloodbath/color-converter.nvim
bindkey('n', '<leader>hsl', function() require('color-converter').to_hsl() end)
bindkey('n', '<leader>rgb', function() require('color-converter').to_rgb() end)

-- buffers and files
bindkey('n', '<leader>g', function() require('telescope.builtin').live_grep() end)
bindkey('n', '<leader>b', function() require('telescope.builtin').buffers() end)
bindkey('n', '<c-p>', function() require('telescope.builtin').find_files() end)
bindkey('n', '<c-h>', ':bprevious<CR>')
bindkey('n', '<c-l>', ':bnext<CR>')
bindkey('n', '<c-t>', ':enew<CR>')
bindkey('n', ',e', ':e <C-R>=expand("%:h")<CR>', {silent = false})

-- movement
bindkey('n', 'G', 'Gzz')
bindkey('n', '<c-j>', '<c-d>zz')
bindkey('n', '<c-k>', '<c-u>zz')

-- search
bindkey('n', '<c-f>', '/', {silent = false}) -- option+7 is mapped by BetterTouchTool instead
bindkey('n', '<c-s>', ':%s!!', {silent = false})

-- signcolumn
bindkey('n', '<leader>c', function()
  local show = vim.wo.signcolumn == 'no'
  vim.wo.signcolumn = show and 'yes' or 'no'
  vim.wo.number = show
  vim.wo.relativenumber = show
end)

-- spelling
bindkey('i', '<leader>ss', function() require('telescope.builtin').spell_suggest() end)
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

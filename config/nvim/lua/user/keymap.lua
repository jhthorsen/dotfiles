local bindkey = require('../utils').bindkey

vim.o.timeoutlen = 350
vim.g.mapleader = ' '

--- NTBBloodbath/color-converter.nvim
bindkey('n', '<leader>hsl', function() require('color-converter').to_hsl() end)
bindkey('n', '<leader>rgb', function() require('color-converter').to_rgb() end)

-- buffers and files
bindkey('n', '<leader>b', function() require('telescope.builtin').buffers() end)
bindkey('n', '<leader>d', function() require('telescope.builtin').diagnostics({bufnr=0}) end)
bindkey('n', '<leader>g', function() require('telescope.builtin').live_grep() end)
bindkey('n', '<leader>q', function() require('../utils').close_buffer_or_nvim() end)
bindkey('n', '<leader>-', ':ExternalHook RefreshFile<CR>')
bindkey('n', '<leader>s', ':w<CR>')
bindkey('n', '<leader>n', ':echo expand("%")<CR>')
bindkey('n', '<tab>', ':bnext<CR>')
bindkey('n', '<s-tab>', ':bprevious<CR>')
bindkey('n', '<c-p>', function() require('telescope.builtin').find_files() end)
bindkey('n', '<c-t>', ':tabnew<CR>')
bindkey('n', ',e', ':e <C-R>=expand("%:h")<CR>', {silent = false})

-- stay in indent mode
bindkey('v', '<', '<gv')
bindkey('v', '>', '>gv')

-- movement
bindkey('n', 'G', 'Gzz')
bindkey('n', '<c-j>', '10j')
bindkey('n', '<c-k>', '10k')
bindkey('n', '<c-b>', '<c-u>zz')
bindkey('n', '<c-f>', '<c-d>zz')

-- search
bindkey('n', '<a-7>', '/', {silent = false})  -- option+7 is mapped to "/" in BTT
bindkey('n', '\\', ':%s!!', {silent = false}) -- option+shift+7 is mapped to "\" in BTT

-- signcolumn
bindkey('n', '<leader>c', function()
  local show = vim.wo.signcolumn == 'no'
  vim.wo.signcolumn = show and 'yes' or 'no'
  vim.wo.number = show
  vim.wo.relativenumber = show
end)

-- venn
bindkey('n', '<leader>v', function()
  local venn_enabled = vim.inspect(vim.b.venn_enabled)
  if venn_enabled == 'nil' then
    vim.b.venn_enabled = true
    vim.cmd[[setlocal ve=all]]
    bindkey('n', 'J', '<C-v>j:VBox<CR>')
    bindkey('n', 'K', '<C-v>k:VBox<CR>')
    bindkey('n', 'L', '<C-v>l:VBox<CR>')
    bindkey('n', 'H', '<C-v>h:VBox<CR>')
    bindkey('v', 'f', ':VBox<CR>')
  else
    vim.cmd[[setlocal ve=]]
    vim.cmd[[mapclear <buffer>]]
    vim.b.venn_enabled = nil
  end
end)

-- visual-multi
bindkey('n', '<c-d>', '<c-n>', {remap = true})
bindkey('v', '<c-d>', '<c-n>', {remap = true})

-- window
bindkey('n', '<leader>h', '<c-w><c-h>')
bindkey('n', '<leader>j', '<c-w><c-j>')
bindkey('n', '<leader>k', '<c-w><c-k>')
bindkey('n', '<leader>l', '<c-w><c-l>')
bindkey('n', '<leader><s-j>', ':resize -3<cr>')
bindkey('n', '<leader><s-k>', ':resize +3<cr>')
bindkey('n', '<leader><s-h>', ':vertical resize -3<cr>')
bindkey('n', '<leader><s-l>', ':vertical resize +3<cr>')

bindkey('n', 'sp', ':sp<CR>')
bindkey('n', 'vs', ':vs<CR>')

local bindkey = require('../utils').bindkey

vim.g.mapleader = ' '

bindkey('n', '<leader>u', require('undotree').toggle, {desc = 'Toggle undotree'})

--- NTBBloodbath/color-converter.nvim
bindkey('n', '<leader>hsl', require('color-converter').to_hsl, {desc = 'Convert color to HSL'})
bindkey('n', '<leader>rgb', require('color-converter').to_rgb, {desc = 'Convert color to RGB'})

-- buffers and files
bindkey('n', '<leader>q', require('../utils').close_buffer_or_nvim, {desc = 'Save and close buffer'})
bindkey('n', '<leader>-', ':ExternalHook RefreshFile<CR>', {desc = 'ExternalHook: Refresh file'})
bindkey('n', '<leader>n', ':echo expand("%")<CR>', {desc = 'Show filename'})
bindkey('n', '<tab>', ':bnext<CR>', {desc = 'Next buffer'})
bindkey('n', '<s-tab>', ':bprevious<CR>', {desc = 'Previous buffer'})
bindkey('n', ',e', ':e <C-R>=expand("%:h")<CR>', {silent = false, desc = 'Find and edit file'})

bindkey('v', '<', '<gv', {desc = 'Indent and stay in indent mode'})
bindkey('v', '>', '>gv', {desc = 'Indent and stay in indent mode'})

-- movement
bindkey('n', 'G', 'Gzz', {desc = 'Move to end and stay in center'})
bindkey('n', '<c-j>', '10j', {desc = 'Jump ten lines down'})
bindkey('n', '<c-k>', '10k', {desc = 'Jump ten lines up'})
bindkey('n', '<c-b>', '<c-u>zz', {desc = 'Jump half a page up and center'})
bindkey('n', '<c-f>', '<c-d>zz', {desc = 'Jump half a page down and center'})

-- search
bindkey('n', '<a-7>', '/', {silent = false, desc = 'Search'})  -- option+7 is mapped to "/" in BTT
bindkey('n', '\\', ':%s!!', {silent = false, desc = 'Search and replace'}) -- option+shift+7 is mapped to "\" in BTT

-- signcolumn
bindkey('n', '<leader>c', function()
  local show = vim.wo.signcolumn == 'no'
  vim.wo.signcolumn = show and 'yes' or 'no'
  vim.wo.number = show
  vim.wo.relativenumber = show
end, {desc = 'Toggle signcolumn'})

-- venn
bindkey('n', '<leader>v', function()
  local venn_enabled = vim.inspect(vim.b.venn_enabled)
  if venn_enabled == 'nil' then
    print('Enable venn')
    vim.b.venn_enabled = true
    vim.cmd[[setlocal ve=all]]
    bindkey('n', 'J', '<C-v>j:VBox<CR>')
    bindkey('n', 'K', '<C-v>k:VBox<CR>')
    bindkey('n', 'L', '<C-v>l:VBox<CR>')
    bindkey('n', 'H', '<C-v>h:VBox<CR>')
    bindkey('v', 'f', ':VBox<CR>')
  else
    print('Disable venn')
    vim.cmd[[setlocal ve=]]
    vim.cmd[[mapclear <buffer>]]
    vim.b.venn_enabled = nil
  end
end, {desc = 'Toggle venn mode (ascii venn diagrams)'})

-- visual-multi
bindkey('n', '<c-d>', '<c-n>', {remap = true, desc = 'Multiple cursors'})
bindkey('v', '<c-d>', '<c-n>', {remap = true, desc = 'Multiple cursors'})

-- window
bindkey('n', '<leader>h', '<c-w><c-h>', {desc = 'Move to window left'})
bindkey('n', '<leader>j', '<c-w><c-j>', {desc = 'Move to window below'})
bindkey('n', '<leader>k', '<c-w><c-k>', {desc = 'Move to window above'})
bindkey('n', '<leader>l', '<c-w><c-l>', {desc = 'Move to window right'})
bindkey('n', '<leader><s-j>', ':resize -3<cr>', {desc = 'Make window smaller horizontally'})
bindkey('n', '<leader><s-k>', ':resize +3<cr>', {desc = 'Make window bigger horizontally'})
bindkey('n', '<leader><s-h>', ':vertical resize -3<cr>', {desc = 'Make window smaller vertically'})
bindkey('n', '<leader><s-l>', ':vertical resize +3<cr>', {desc = 'Make window bigger vertically'})

bindkey('n', '<leader>wv', ':sp<CR>', {desc = 'Split window vertically'})
bindkey('n', '<leader>wh', ':vs<CR>', {desc = 'Split window horizontally'})

local bindkey = vim.keymap.set

function netrw_bindkey(key, cmd)
  vim.cmd('autocmd filetype netrw nmap <buffer> ' .. key .. ' ' .. cmd)
end

vim.g.netrw_altv = 0
vim.g.netrw_banner = 0
vim.g.netrw_browse_split = 4
vim.g.netrw_fastbrowse = 2
vim.g.netrw_keepdir = 0
vim.g.netrw_liststyle = 3
vim.g.netrw_winsize = 30

bindkey('n', '<leader>e', ':Lexplore<CR>')
bindkey('n', '<leader>f', ':silent Lexplore %:p:h<CR>')

netrw_bindkey('e', '<CR>:Lexplore<CR>')
netrw_bindkey('h', 'gh')
netrw_bindkey('<leader><tab>', 'mu')
netrw_bindkey('<s-tab>', 'mF')
netrw_bindkey('<tab>', 'mf')

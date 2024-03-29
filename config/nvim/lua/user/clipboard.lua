local bindkey = require('../utils').bindkey

bindkey('v', '<c-y>', ':w !snipclip -i<CR><CR>')
bindkey('i', '<c-p>', '<ESC>:set paste<CR>:r !snipclip -o<CR>:set nopaste<CR>a')

-- 0dd, 0de, ... does not cut - it just deletes
bindkey('n', '0d', '"_d')
bindkey('v', '0d', '"_d')

vim.api.nvim_create_autocmd({'TextYankPost'}, {callback = function()
  if vim.v.event.operator == 'y' then
    local fh = io.popen('snipclip -i', 'w')
    if fh == nil then return end
    fh:write(vim.fn.getreg('"'))
    fh:close()
  end
end});

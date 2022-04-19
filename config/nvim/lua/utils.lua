local M = {}
local cmd = vim.cmd

function M.autocmd(name, autocmds)
  cmd('augroup user_' .. name)
  cmd('autocmd!')
  for _, autocmd in ipairs(autocmds) do
    cmd('autocmd ' .. table.concat(autocmd, ' '))
  end
  cmd('augroup END')
end

return M

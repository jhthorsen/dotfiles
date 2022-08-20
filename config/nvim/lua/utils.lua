local M = {}

function M.bindkey(mode, key, action, opts)
  local options = {silent = true}
  if opts then options = vim.tbl_extend('force', options, opts) end
  vim.keymap.set(mode, key, action, options)
end

return M

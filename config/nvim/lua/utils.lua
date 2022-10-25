local M = {}

function M.bindkey(mode, key, action, opts)
  local options = {silent = true}
  if opts then options = vim.tbl_extend('force', options, opts) end
  vim.keymap.set(mode, key, action, options)
end

function M.use(name, setup)
  local ok, mod = pcall(require, name)
  if ok == false then return print('Unable to load plugin ' .. name) end
  if setup then setup(mod) end
end

return M

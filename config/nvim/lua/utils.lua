-- https://github.com/nanotee/nvim-lua-guide
local api = vim.api;
local fn = vim.fn;

local M = {}

function M.bindkey(mode, key, action, opts)
  local options = {silent = true}
  if opts then options = vim.tbl_extend('force', options, opts) end
  vim.keymap.set(mode, key, action, options)
end

function M.dump(table)
  print(vim.inspect(table))
end

function M.close_buffer_or_nvim(cmd)
  local saved = not api.nvim_buf_get_option(api.nvim_get_current_buf(), 'modified')

  if #vim.fn.getbufinfo({buflisted = 1}) <= 1 then
    return saved and api.nvim_command('quit') or print('Will not abandon unsaved buffer')
  end

  if cmd == nil then
    cmd = saved and 'bd' or 'w|bd';
  end

  api.nvim_command(cmd)
end

function M.use(name, setup)
  local ok, mod = pcall(require, name)
  if ok == false then return print('Unable to load plugin ' .. name) end
  if setup then setup(mod) end
end

return M

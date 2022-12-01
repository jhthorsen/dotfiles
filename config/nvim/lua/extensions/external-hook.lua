local dirname = require('../utils').dirname
local hook_script = nil
local vim_leave = false

local find_hook_script = function(path)
  while #path > 1 do
    path = dirname(path)
    local script = path .. '/.nvim-external-hook'
    local stat = vim.loop.fs_stat(script)
    if stat then return script end
  end

  return ''
end

local hook = function(params)
  local file = vim.api.nvim_buf_get_name(0)
  if hook_script == nil then hook_script = find_hook_script(file) end
  if hook_script == '' then return end

  local event_name = params.args and params.args or params.event
  local handle = vim.loop.spawn(
    hook_script,
    {args = {event_name, file}},
    function(code, signal)
      if code ~= 2 and not vim_leave then
        print(event_name .. ' ' .. file .. ' = ' .. code)
      end
    end
  )
end

vim.api.nvim_create_autocmd({'BufNewFile', 'BufReadPost', 'BufWritePost'}, {callback = hook})
vim.api.nvim_create_autocmd('VimLeave', {callback = function() vim_leave = true end})
vim.api.nvim_create_user_command('ExternalHook', hook, {nargs = 1})

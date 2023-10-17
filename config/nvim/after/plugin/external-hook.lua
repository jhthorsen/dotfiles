local dirname = require('../utils').dirname
local hook_script = nil
local prevent_recursion = {}
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
  if prevent_recursion[event_name] then
    prevent_recursion[event_name] = false
    return
  end

  vim.loop.spawn(
    hook_script,
    {args = {event_name, file}},
    vim.schedule_wrap(function(code, _)
      if code ~= 0 and code ~= 2 and not vim_leave then
        print(event_name .. ' ' .. file .. ' = ' .. code)
      end
      if code == 35 then
        prevent_recursion[event_name] = true
        vim.cmd('edit')
      end
    end)
  )
end

vim.api.nvim_create_autocmd({'BufNewFile', 'BufReadPre', 'BufReadPost', 'BufWritePost'}, {callback = hook})
vim.api.nvim_create_autocmd({'VimLeave'}, {callback = function() vim_leave = true end})
vim.api.nvim_create_user_command('ExternalHook', hook, {nargs = 1})

local hook_script = nil
local vim_leave = false

local hook = function(hook_name)
  local file = vim.api.nvim_buf_get_name(0)

  if hook_script == nil then
    local dir = file
    while #dir > 1 do
      dir = vim.fs.dirname(dir)
      local file = dir .. '/.nvim-external-hook'
      local stat = vim.loop.fs_stat(file)
      if stat then
        hook_script = file
        break
      end
    end
  end

  if hook_script ~= nil then
    local handle = vim.loop.spawn(
      hook_script,
      {args = {hook_name, file}},
      function(code, signal)
        if code ~= 2 and not vim_leave then
          print(hook_name .. ' ' .. file .. ' = ' .. code)
        end
      end
    )
  end
end

vim.api.nvim_create_autocmd('BufNewFile', {callback = function() hook('BufNewFile') end})
vim.api.nvim_create_autocmd('BufReadPost', {callback = function() hook('BufReadPost') end})
vim.api.nvim_create_autocmd('BufWritePost', {callback = function() hook('BufWritePost') end})
vim.api.nvim_create_autocmd('VimLeave', {callback = function() vim_leave = true end})

local fn = vim.fn

vim.api.nvim_create_autocmd({'BufWritePre'}, {callback = function()
  local dir = fn.expand('<afile>:p:h')
  if dir:find('%l+://') == 1 then return end
  if fn.isdirectory(dir) == 0 then fn.mkdir(dir, 'p') end
end})

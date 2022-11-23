local use = require('utils').use;

vim.g.spell_under = 'kanagawa'
use('kanagawa', function (mod)
  mod.setup({
    dimInactive = true,
    transparent = true,
  })
end)

vim.o.background = 'dark'
vim.o.cmdheight = 1
vim.o.laststatus = 0
vim.o.number = true
vim.o.numberwidth = 4
vim.o.relativenumber = true
vim.o.ruler = false
vim.o.showcmd = false
vim.o.showmode = false
vim.o.signcolumn = 'yes'
vim.o.termguicolors = true

vim.api.nvim_exec([[
  syntax match NonASCII "[^\x00-\x7F]"
  highlight NonASCII ctermbg=red guibg=red
  highlight NonText ctermbg=none guibg=none guifg=250
  highlight Normal ctermbg=none guibg=none guifg=252
]], false)

vim.o.showtabline = 0
vim.o.statusline = ''

local ok, mod = pcall(require, 'lualine')
if ok then
  mod.setup({
    sections = {
      lualine_a = {{'buffers', max_length = 100, mode = 0, symbols = {alternate_file = ''}}},
      lualine_b = {},
      lualine_c = {},
      lualine_x = {'diagnostics'},
      lualine_y = {'%B'},
      lualine_z = {'progress', 'location'},
    },
    options = {
      globalstatus = true,
      icons_enabled = true,
      theme = 'jellybeans',
      component_separators = { left = '', right = ''},
      section_separators = { left = '', right = ''},
    },
    -- inactive_sections = {},
    statusline = {},
    tabline = {},
  })
end

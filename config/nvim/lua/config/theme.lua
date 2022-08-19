vim.o.background = 'dark'
vim.o.termguicolors = true
vim.g.spell_under = 'gruvbox-baby'

local colors = require('gruvbox-baby.colors').config()

vim.g.gruvbox_baby_background_color = 'dark'
vim.g.gruvbox_baby_transparent_mode = true

vim.api.nvim_exec([[
  syntax match NonASCII "[^\x00-\x7F]"
  highlight NonASCII ctermbg=red guibg=red
  highlight NonText ctermbg=none guibg=none guifg=250
  highlight Normal ctermbg=none guibg=none guifg=252
]], false)

local ok, mod = pcall(require, 'lualine')
if ok then
  mod.setup({
    sections = {
      lualine_a = {'buffers'},
      lualine_b = {},
      lualine_c = {},
      lualine_x = {'diff', 'diagnostics'},
      lualine_y = {'filetype'},
      lualine_z = {'progress', 'location'},
    },
    options = {
      globalstatus = true,
      icons_enabled = false,
      theme = 'gruvbox-baby',
    },
  })
end

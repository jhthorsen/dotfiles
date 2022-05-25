vim.o.background = 'dark'
vim.o.spell = true
vim.o.termguicolors = true
vim.g.spell_under = 'tokyonight';
vim.g.tokyonight_sidebars = {'qf', 'vista_kind', 'terminal', 'packer'}
vim.g.tokyonight_style = 'night'
vim.g.tokyonight_transparent = true

vim.g.tokyonight_colors = {fg_gutter = '#707cb2', comment = '#707cb2'}

vim.api.nvim_exec([[
  syntax match NonASCII "[^\x00-\x7F]"
  highlight NonASCII ctermbg=red guibg=red
  highlight NonText ctermbg=none guibg=none guifg=250
  highlight Normal ctermbg=none guibg=none guifg=252
]], false)

local ok, mod = pcall(require, 'lualine')
if ok then
  local tokyonight = require('lualine/themes/tokyonight')
  local bg = '#23283b'
  tokyonight.command.b.bg = bg
  tokyonight.insert.b.bg = bg
  tokyonight.normal.b.bg = bg
  tokyonight.replace.b.bg = bg
  tokyonight.visual.b.bg = bg

  mod.setup({
    sections = {
      lualine_a = {'branch'},
      lualine_b = {'diff', 'diagnostics'},
      lualine_c = {{'filename', path = 1}},
      lualine_x = {'encoding'},
      lualine_y = {'filetype'},
      lualine_z = {'progress', 'location'},
    },
    inactive_sections = {
      lualine_a = {},
      lualine_b = {{'filename', path = 1}},
      lualine_c = {},
      lualine_x = {},
      lualine_y = {},
      lualine_z = {'location'},
    },
    options = {
      theme = tokyonight,
    }
  })
end

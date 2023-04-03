local use = require('utils').use;

vim.g.spell_under = 'kanagawa'
use('kanagawa', function (kanagawa)
  kanagawa.setup({
    dimInactive = true,
    transparent = true,
  })
end)

vim.api.nvim_exec([[
  syntax match NonASCII "[^\x00-\x7F]"
  highlight NonASCII ctermbg=red guibg=red
  highlight NonText ctermbg=none guibg=none guifg=250
  highlight Normal ctermbg=none guibg=none guifg=252
]], false)

local function max_length()
  return vim.o.columns - 50
end

use('lualine', function(lualine)
  lualine.setup({
    sections = {
      lualine_a = {{'buffers', max_length = max_length, mode = 0, symbols = {alternate_file = ''}}},
      lualine_b = {{'filename', file_status = false, path = 1, shorting_target = 90}},
      lualine_c = {},
      lualine_x = {},
      lualine_y = {},
      lualine_z = {'progress', 'selectioncount', 'location'},
    },
    options = {
      always_divide_middle = true,
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
end)

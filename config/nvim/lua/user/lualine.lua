local use = require('utils').use;

local function buffers_max_length()
  return vim.o.columns - 20
end

use('lualine', function(lualine)
  lualine.setup({
    sections = {
      lualine_a = {{'buffers', max_length = buffers_max_length, mode = 0, symbols = {alternate_file = ''}}},
      lualine_b = {},
      lualine_c = {},
      lualine_x = {},
      lualine_y = {'selectioncount'},
      lualine_z = {'progress', 'location'},
    },
    options = {
      always_divide_middle = true,
      globalstatus = true,
      icons_enabled = true,
      component_separators = { left = '', right = ''},
      section_separators = { left = '', right = ''},
    },
    -- inactive_sections = {},
    statusline = {},
    tabline = {},
  })
end)

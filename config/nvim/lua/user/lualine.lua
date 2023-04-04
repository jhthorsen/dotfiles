local use = require('utils').use;

local function buffers_max_length()
  return vim.o.columns - 50
end

local function maybe_show_buffers()
  return #vim.fn.getbufinfo({buflisted = 1}) > 1
end

local function mode()
  local m = vim.api.nvim_get_mode().mode
  if string.sub(m, 0, 1) == 'c' then return 'C' end
  if string.sub(m, 0, 1) == 'i' then return 'I' end
  if string.sub(m, 0, 1) == 'n' then return 'N' end
  if string.sub(m, 0, 1) == 'R' then return 'R' end
  if string.sub(m, 0, 1) == 't' then return 'T' end
  if string.sub(m, 0, 1) == 'v' then return 'V' end
  if string.sub(m, 0, 1) == 'V' then return 'L' end
  if string.sub(m, 0, 1) == '!' then return 'S' end
  return '?'
end

use('lualine', function(lualine)
  lualine.setup({
    sections = {
      lualine_a = {{'buffers', cond = maybe_show_buffers, max_length = buffers_max_length, mode = 0, symbols = {alternate_file = ''}}},
      lualine_b = {mode},
      lualine_c = {{'filename', file_status = false, path = 1, shorting_target = 90}},
      lualine_x = {},
      lualine_y = {},
      lualine_z = {'selectioncount', 'progress', 'location'},
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

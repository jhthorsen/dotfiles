local colors = require('gruvbox.colors')
local vi_mode_utils = require('feline.providers.vi_mode')

local M = {
  active = {},
  inactive = {},
}

M.active[1] = {
  {
    provider = '▊ ',
    hl = {fg = colors.neutral_blue},
 },
  {
    provider = 'vi_mode',
    hl = function()
      return {
        name = vi_mode_utils.get_mode_highlight_name(),
        fg = vi_mode_utils.get_mode_color(),
        style = 'bold',
     }
    end,
 },
  {
    provider = 'file_info',
    hl = {fg = colors.dark0, bg = colors.neutral_blue, style = 'bold'},
    left_sep = {
      'slant_left_2',
      {str = ' ', hl = {bg = colors.neutral_blue, fg = colors.dark0}},
   },
    right_sep = {
      {str = ' ', hl = {bg = colors.neutral_blue, fg = colors.dark0}},
      'slant_right_2',
      ' ',
   },
 },
  {
    provider = 'file_size',
    right_sep = {
      ' ',
      {
        str = 'slant_left_2_thin',
        hl = {fg = 'fg', bg = 'bg'},
     },
   },
 },
  {
    provider = 'position',
    left_sep = ' ',
    right_sep = {
      ' ',
      {
        str = 'slant_right_2_thin',
        hl = {fg = 'fg', bg = 'bg'},
     },
   },
 },
  {
    provider = 'diagnostic_errors',
    hl = {fg = colors.red},
 },
  {
    provider = 'diagnostic_warnings',
    hl = {fg = colors.neutral_yellow},
 },
  {
    provider = 'diagnostic_hints',
    hl = {fg = colors.neutral_green},
 },
  {
    provider = 'diagnostic_info',
    hl = {fg = colors.faded_blue},
 },
}

M.active[2] = {
  {
    provider = 'git_branch',
    hl = {fg = colors.light0, bg = colors.dark0, style = 'bold'},
    right_sep = {
      str = ' ',
      hl = {fg = 'NONE', bg = colors.dark0},
   },
 },
  {
    provider = 'git_diff_added',
    hl = {fg = colors.green, bg = colors.dark0},
 },
  {
    provider = 'git_diff_changed',
    hl = {fg = colors.neutral_orange, bg = colors.dark0},
 },
  {
    provider = 'git_diff_removed',
    hl = {fg = colors.red, bg = colors.dark0},
    right_sep = {
      str = ' ',
      hl = {fg = 'NONE', bg = colors.dark0},
   },
 },
  {
    provider = 'line_percentage',
    hl = {style = 'bold'},
    left_sep = '  ',
    right_sep = ' ',
 },
  {
    provider = 'scroll_bar',
    hl = {fg = colors.faded_blue, style = 'bold'},
 },
}

M.inactive[1] = {
  {
    provider = 'file_type',
    hl = {fg = colors.dark0, bg = colors.bright_blue, style = 'bold'},
    left_sep = {
      str = ' ',
      hl = {fg = 'NONE', bg = colors.bright_blue},
   },
    right_sep = {
      {
        str = ' ',
        hl = {fg = 'NONE', bg = colors.bright_blue},
     },
      'slant_right',
   },
 },
  -- Empty component to fix the highlight till the end of the statusline
  {},
}

return M

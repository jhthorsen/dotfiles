vim.g.spell_under = 'gruvbox-baby'
vim.o.background = 'dark'
vim.o.laststatus = 1
vim.o.number = true
vim.o.numberwidth = 4
vim.o.relativenumber = true
vim.o.ruler = true
vim.o.showmode = false
vim.o.showcmd = true
vim.o.signcolumn = 'yes'
vim.o.termguicolors = true

local colors = require('gruvbox-baby.colors').config()

vim.g.gruvbox_baby_background_color = 'dark'
vim.g.gruvbox_baby_transparent_mode = true

vim.api.nvim_exec([[
  syntax match NonASCII "[^\x00-\x7F]"
  highlight NonASCII ctermbg=red guibg=red
  highlight NonText ctermbg=none guibg=none guifg=250
  highlight Normal ctermbg=none guibg=none guifg=252
]], false)

require('bufferline').setup({
  options = {
    custom_areas = {
      right = function()
        local result = {}
        local seve = vim.diagnostic.severity
        local error = #vim.diagnostic.get(0, {severity = seve.ERROR})
        local warning = #vim.diagnostic.get(0, {severity = seve.WARN})

        if error ~= 0 then table.insert(result, {text = '  ' .. error, fg = '#EC5241'}) end
        if warning ~= 0 then table.insert(result, {text = '  ' .. warning, fg = '#EFB839'}) end

        return result
      end,
    },

    mode = 'buffers',
    numbers = 'none',
    close_command = 'bdelete! %d',
    left_mouse_command = 'buffer %d',
    middle_mouse_command = nil,
    right_mouse_command = nil,

    indicator = {style = 'none'},
    modified_icon = '●',
    separator_style = {'|', '|'},
    left_trunc_marker = '',
    right_trunc_marker = '',

    max_name_length = 22,
    max_prefix_length = 8,
    tab_size = 8,

    always_show_bufferline = true,
    color_icons = true,
    diagnostics = false,
    enforce_regular_tabs = false,
    show_buffer_close_icons = false,
    show_buffer_default_icon = true,
    show_buffer_icons = true,
    show_close_icon = false,
    show_tab_indicators = false,
  },
})

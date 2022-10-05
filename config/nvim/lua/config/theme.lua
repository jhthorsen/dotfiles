vim.g.spell_under = 'codedark'
vim.g.codedark_conservative = 0
vim.g.codedark_transparent = 1
vim.g.codedark_italics = 1

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
vim.o.winbar = ''

local function number_of_buffers()
  return #vim.fn.getbufinfo({buflisted = 1})
end

local ok, mod = pcall(require, 'lualine')
if ok then
  mod.setup({
    sections = {
      lualine_a = {number_of_buffers},
      lualine_b = {{'tabs', max_length = 100, mode = 1}},
      lualine_c = {},
      lualine_x = {'%B', 'diff', 'diagnostics'},
      lualine_y = {'filetype', },
      lualine_z = {'progress', 'location'},
    },
    options = {
      globalstatus = true,
      icons_enabled = true,
      theme = 'jellybeans',
    },
    -- inactive_sections = {},
    statusline = {},
    tabline = {},
    winbar = {},
  })
end

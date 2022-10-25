-- https://github.com/neovim/neovim/tree/master/runtime/lua/vim
-- https://icyphox.sh/blog/nvim-lua/
-- https://www.lua.org/pil/contents.html

vim.o.completeopt = 'menu,menuone,noselect'
vim.o.errorbells = false
vim.o.expandtab = true
vim.o.foldenable = false
vim.o.hlsearch = false
vim.o.incsearch = true
vim.o.lazyredraw = true
vim.o.mouse = '' -- shift to disable
vim.o.mousemodel = 'popup'
vim.o.mousescroll = 'ver:1,hor:5'
vim.o.scrolloff = 12
vim.o.shiftwidth = 2
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.swapfile = false
vim.o.tabstop = 2
vim.o.virtualedit = 'block'
vim.o.wrap = false

local use = require('utils').use;

use('config/keymap')
use('config/netrw')
use('config/syntax')
use('config/clipboard')
use('config/theme')
use('config/lsp')
use('config/cmp')
use('config/treesitter')
use('config/telescope')

use('extensions/sync-file')
use('nvim-surround', function (mod) mod.setup({}) end)
use('Comment', function (mod) mod.setup() end)

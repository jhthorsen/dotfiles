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
vim.o.mouse = ''
vim.o.scrolloff = 12
vim.o.shiftwidth = 2
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.swapfile = false
vim.o.tabstop = 2
vim.o.virtualedit = 'block'
vim.o.wildmenu = true
vim.o.wildmode = 'longest,list,full'
vim.o.wrap = false

local use = require('utils').use;

use('user/keymap')
use('user/netrw')
use('user/clipboard')
use('user/theme')
use('user/lsp')
use('user/cmp')
use('user/syntax')
use('user/treesitter')
use('user/telescope')

use('extensions/external-hook')
use('nvim-surround', function (mod) mod.setup({}) end)
use('Comment', function (mod) mod.setup() end)

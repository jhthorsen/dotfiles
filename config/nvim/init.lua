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

-- TODO: Are these plugins loaded?
-- ap/vim-css-color
-- lucas1/vim-perl
-- mattn/emmet-vim
-- osamuaoki/vim-spell-under
-- yko/mojo.vim

local ok, mod = pcall(require, 'telescope')

local ok, mod = pcall(require, 'nvim-surround')
if ok then mod.setup({}) end

local ok, mod = pcall(require, 'Comment')
if ok then mod.setup() end

require('config/keymap')
require('config/netrw')
require('config/syntax')
require('config/clipboard')
require('extensions/sync-file')

local ok, mod = pcall(require, 'config/theme')
local ok, mod = pcall(require, 'config/lsp')
local ok, mod = pcall(require, 'config/cmp')
local ok, mod = pcall(require, 'config/telescope')
local ok, mod = pcall(require, 'config/treesitter')

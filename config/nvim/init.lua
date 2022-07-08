-- https://github.com/neovim/neovim/tree/master/runtime/lua/vim
-- https://icyphox.sh/blog/nvim-lua/
-- https://www.lua.org/pil/contents.html

-- basics
vim.o.completeopt = 'menu,menuone,noselect'
vim.o.errorbells = false
vim.o.expandtab = true
vim.o.foldenable = false
vim.o.hlsearch = false
vim.o.incsearch = true
vim.o.lazyredraw = true
vim.o.number = true
vim.o.numberwidth = 4
vim.o.relativenumber = true
vim.o.scrolloff = 6
vim.o.shiftwidth = 2
vim.o.showtabline = 2
vim.o.signcolumn = 'yes'
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.swapfile = false
vim.o.tabstop = 2
vim.o.wrap = false

vim.g.instant_username = 'jhthorsen'

require('config/keymap')
require('config/netrw')
require('config/syntax')
require('config/clipboard')
require('extensions/sync-file')

-- external extensions
return require('packer').startup(function()
  use {'wbthomason/packer.nvim'}
  use {'ap/vim-css-color', ft = {'css', 'html', 'scss'}}
  use {'folke/tokyonight.nvim'}
  use {'hrsh7th/nvim-cmp', requires = {
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-path',
    'L3MON4D3/LuaSnip',
  }}
  use {'jbyuki/instant.nvim'}
  use {'kyazdani42/nvim-web-devicons'}
  use {'lucas1/vim-perl', branch = 'dev'}
  use {'mattn/emmet-vim', ft = {'ep', 'epl', 'html', 'svelte'}}
  use {'mg979/vim-visual-multi'}
  use {'neovim/nvim-lspconfig'}
  use {'nvim-lualine/lualine.nvim', requires = {'kyazdani42/nvim-web-devicons', opt = true}}
  use {'nvim-telescope/telescope.nvim', requires = {'nvim-lua/plenary.nvim'}}
  use {'nvim-treesitter/nvim-treesitter'}
  use {'osamuaoki/vim-spell-under'}
  use {'yko/mojo.vim', ft = {'ep', 'epl'}}

  local ok, mod = pcall(require, 'config/theme')
  local ok, mod = pcall(require, 'config/lsp')
  local ok, mod = pcall(require, 'config/cmp')
  local ok, mod = pcall(require, 'config/telescope')
  local ok, mod = pcall(require, 'config/treesitter')
end)

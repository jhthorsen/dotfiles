-- https://github.com/neovim/neovim/tree/master/runtime/lua/vim
-- https://icyphox.sh/blog/nvim-lua/
-- https://www.lua.org/pil/contents.html

-- basics
vim.o.completeopt = 'menu,menuone,noselect'
vim.o.errorbells = false
vim.o.expandtab = true
vim.o.hlsearch = false
vim.o.ignorecase = true
vim.o.incsearch = true
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
vim.o.termguicolors = true
vim.o.wrap = false

-- netrw
vim.g.netrw_altv = 0
vim.g.netrw_banner = 0
vim.g.netrw_browse_split = 4
vim.g.netrw_fastbrowse = 2
vim.g.netrw_keepdir = 0
vim.g.netrw_liststyle = 3
vim.g.netrw_winsize = 30

-- grouped config and local extensions
require('config/keymap')
require('config/clipboard')
require('extensions/sync-file')

-- external extensions
return require('packer').startup(function()
  use {'wbthomason/packer.nvim'}
  use {'ap/vim-css-color', ft = {'css', 'html', 'scss'}}
  use {'gruvbox-community/gruvbox'}
  use {'hrsh7th/cmp-buffer'}
  use {'hrsh7th/cmp-nvim-lsp'}
  use {'hrsh7th/nvim-cmp'}
  use {'mattn/emmet-vim', ft = {'ep', 'epl', 'html', 'svelte'}}
  use {'mg979/vim-visual-multi'}
  use {'neovim/nvim-lspconfig'}
  use {'nvim-lualine/lualine.nvim', requires = {'kyazdani42/nvim-web-devicons', opt = true}}
  use {'nvim-telescope/telescope.nvim', requires = {'nvim-lua/plenary.nvim'}}
  use {'nvim-treesitter/nvim-treesitter'}
  use {'yko/mojo.vim', ft = {'ep', 'epl'}}

  require('lualine').setup()
  require('config/theme')
  require('config/lsp')
  require('config/cmp')
  require('config/telescope')
  require('config/treesitter')
end)

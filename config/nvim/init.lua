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
vim.o.wrap = false

require('config/keymap')
require('config/netrw')
require('config/syntax')
require('config/clipboard')
require('extensions/sync-file')

-- external extensions
return require('packer').startup(function()
  use {'wbthomason/packer.nvim'}
  use {'akinsho/bufferline.nvim', requires = 'kyazdani42/nvim-web-devicons'}
  use {'ap/vim-css-color'}
  use {'hrsh7th/nvim-cmp', requires = {
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-path',
    'L3MON4D3/LuaSnip',
  }}
  use {'kylechui/nvim-surround', config = function() require('nvim-surround').setup() end}
  use {'lucas1/vim-perl', branch = 'dev'}
  use {'mattn/emmet-vim'}
  use {'mg979/vim-visual-multi'}
  use {'neovim/nvim-lspconfig'}
  use {'numToStr/Comment.nvim', config = function() require('Comment').setup() end} -- gcc, gci{, gbat
  use {'NTBBloodbath/color-converter.nvim'}
  use {'nvim-telescope/telescope.nvim', requires = {'nvim-lua/plenary.nvim'}}
  use {'nvim-treesitter/nvim-treesitter'}
  use {'osamuaoki/vim-spell-under'}
  use {'tomasiser/vim-code-dark'}
  use {'yko/mojo.vim', ft = {'ep', 'epl'}}

  local ok, mod = pcall(require, 'config/theme')
  local ok, mod = pcall(require, 'config/lsp')
  local ok, mod = pcall(require, 'config/cmp')
  local ok, mod = pcall(require, 'config/telescope')
  local ok, mod = pcall(require, 'config/treesitter')
end)

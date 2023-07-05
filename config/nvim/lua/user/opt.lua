vim.opt.foldenable = false
vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.mouse = ''
vim.opt.scrolloff = 8
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.virtualedit = 'block'
vim.opt.wrap = false

vim.opt.completeopt = 'menu,menuone,noselect'
vim.opt.wildmenu = true
vim.opt.wildmode = 'longest,list,full'
vim.opt.isfname:append("@-@")

vim.opt.backup = false
vim.opt.clipboard = 'unnamed'
vim.opt.timeoutlen = 250
vim.opt.swapfile = false
vim.opt.undodir = os.getenv('HOME') .. '/.cache/nvim/undo'
vim.opt.undofile = true
vim.opt.updatetime = 250

vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.tabstop = 2
vim.opt.smartindent = true

vim.opt.background = 'dark'
vim.opt.cmdheight = 1
vim.opt.colorcolumn = {80, 100}
vim.opt.errorbells = false
vim.opt.lazyredraw = true
vim.opt.number = true
vim.opt.numberwidth = 4
vim.opt.relativenumber = true
vim.opt.ruler = false
vim.opt.showcmd = false
vim.opt.showmode = false
vim.opt.showtabline = 0
vim.opt.signcolumn = 'yes'
vim.opt.termguicolors = true

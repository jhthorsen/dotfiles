-- https://github.com/neovim/neovim/tree/master/runtime/lua/vim
-- https://icyphox.sh/blog/nvim-lua/
-- https://www.lua.org/pil/contents.html

-- TODO
-- https://github.com/brymer-meneses/grammar-guard.nvim
-- https://github.com/jose-elias-alvarez/typescript.nvim

local use = require('utils').use;

use('user/opt')
use('user/keymap')
use('user/netrw')
use('user/clipboard')
use('user/theme')
use('user/lualine')
use('user/lsp')
use('user/cmp')
use('user/syntax')
use('user/treesitter')
use('user/telescope')

use('Comment', function (mod) mod.setup() end)
use('undotree', function (mod) mod.setup({float_diff = true, window = {winblend = 10}}) end)

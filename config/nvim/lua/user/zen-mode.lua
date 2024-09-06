local bindkey = require('../utils').bindkey

bindkey('n', '<leader>z', function()
  require("zen-mode").toggle({
    window = {
      backdrop = 1,
      height = 0.9,
      width = 100,
      options = {
        cursorcolumn = false,
        cursorline = false,
        foldcolumn = "0",
        list = false,
        number = false,
        relativenumber = false,
        signcolumn = "no",
      },
    },
    plugins = {
      options = {
        enabled = true,
      },
      wezterm = {
        enabled = true,
        font = "+3",
      },
    },
    on_open = function(win)
      vim.opt.colorcolumn = {}
      vim.opt.linebreak = true
      vim.opt.wrap = true
    end,
    on_close = function(win)
      vim.opt.colorcolumn = {80, 100}
      vim.opt.linebreak = false
      vim.opt.wrap = false
    end,
  })
end, {desc = 'Enable zen-mode', silent = false});

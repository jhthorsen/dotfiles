local use = require('utils').use;

vim.g.spell_under = 'kanagawa'

-- This comment exists to make overrides() below easier to test

use('kanagawa', function(kanagawa)
  kanagawa.setup({
    compile = false,
    transparent = true,
    dimInactive = true,
    overrides = function(colors)
      local theme = colors.theme
      return {
        Comment = { bg = theme.ui.bg_dim, fg = theme.ui.fg_dim },
      }
    end,
  })
end)

vim.api.nvim_exec([[
  syntax match NonASCII "[^\x00-\x7F]"
  highlight NonASCII ctermbg=red guibg=red
  highlight NonText ctermbg=none guibg=none guifg=250
  highlight Normal ctermbg=none guibg=none guifg=252
]], false)

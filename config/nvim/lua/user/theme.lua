local use = require('utils').use;

vim.g.spell_under = 'kanagawa-wave'

-- This comment exists to make overrides() below easier to test
-- To check the word under the cursor: ":Inspect"

use('kanagawa', function(kanagawa)
  -- local palette = require('kanagawa.colors').setup({theme = 'wave'}).palette
  kanagawa.setup({
    compile = false,
    dimInactive = true,
    commentStyle = { bold = false, italic = true },
    keywordStyle = { bold = false, italic = false },
    statementStyle = { bold = false, italic = false },
    transparent = false,
    theme = 'wave',
    colors = {
      theme = {
        wave = {
          ui = {
            float = {
              bg = 'none',
            },
          },
          syn = {
          },
        },
      },
    },
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

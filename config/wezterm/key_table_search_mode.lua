local wezterm = require 'wezterm'
local act = wezterm.action

return {
  {key = 'Escape', mods = 'NONE',        action = act.CopyMode 'Close'},
  {key = '[',      mods = 'SUPER',       action = 'ActivateCopyMode'},
  {key = 'n',      mods = 'SUPER',       action = act.CopyMode 'PriorMatch'},
  {key = 'N',      mods = 'SUPER|SHIFT', action = act.CopyMode 'NextMatch'},
  {key = 'r',      mods = 'SUPER',       action = act.CopyMode 'CycleMatchType'},
  {key = 'u',      mods = 'SUPER',       action = act.CopyMode 'ClearPattern'},
}
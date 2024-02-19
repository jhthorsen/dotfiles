local wezterm = require 'wezterm'
local act = wezterm.action

local copy = act.Multiple {
  act.CopyTo 'ClipboardAndPrimarySelection',
  act.CopyMode 'Close',
}

return {
  {key = 'Escape', mods = 'NONE',        action = act.CopyMode 'Close'},
  {key = 'v',      mods = 'NONE',        action = act.CopyMode {SetSelectionMode = 'Cell'}},
  {key = 'v',      mods = 'SUPER',       action = act.CopyMode {SetSelectionMode = 'Block'}},
  {key = 'n',      mods = 'SUPER',       action = act.CopyMode 'PriorMatch'},
  {key = 'n',      mods = 'SUPER|SHIFT', action = act.CopyMode 'NextMatch'},
  {key = 'u',      mods = 'SUPER',       action = act.CopyMode 'ClearPattern'},
  {key = 'y',      mods = 'NONE',        action = copy},
  {key = 'f',      mods = 'NONE',        action = act.Search {CaseSensitiveString = ''}},
  {key = 'h',      mods = 'NONE',        action = act.CopyMode 'MoveLeft'},
  {key = 'j',      mods = 'NONE',        action = act.CopyMode 'MoveDown'},
  {key = 'k',      mods = 'NONE',        action = act.CopyMode 'MoveUp'},
  {key = 'l',      mods = 'NONE',        action = act.CopyMode 'MoveRight'},
  {key = 'e',      mods = 'NONE',        action = act.CopyMode 'MoveForwardWord'},
  {key = 'b',      mods = 'NONE',        action = act.CopyMode 'MoveBackwardWord'},
  {key = '$',      mods = 'NONE',        action = act.CopyMode 'MoveToEndOfLineContent'},
  {key = '0',      mods = 'NONE',        action = act.CopyMode 'MoveToStartOfLine'},
}

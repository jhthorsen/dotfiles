local wezterm = require 'wezterm'
local act = wezterm.action
local M = {}

local clearScrollbackAndSendClearKey = act.Multiple({
  act.ClearScrollback('ScrollbackAndViewport'),
  act.SendString('\x03'),
  act.SendString('clear -a'),
  act.SendString('\x0d'),
})

M.copy_mode = {
  {key = 'Escape', mods = 'NONE',        action = act.CopyMode('Close')},
  {key = 'v',      mods = 'NONE',        action = act.CopyMode({SetSelectionMode = 'Cell'})},
  {key = 'v',      mods = 'SUPER',       action = act.CopyMode({SetSelectionMode = 'Block'})},
  {key = 'n',      mods = 'SUPER',       action = act.CopyMode('PriorMatch')},
  {key = 'n',      mods = 'SUPER|SHIFT', action = act.CopyMode('NextMatch')},
  {key = 'u',      mods = 'SUPER',       action = act.CopyMode('ClearPattern')},
  {key = 'y',      mods = 'NONE',        action = act.Multiple({act.CopyTo 'ClipboardAndPrimarySelection', act.CopyMode 'Close'})},
  {key = 'f',      mods = 'NONE',        action = act.Search({CaseSensitiveString = ''})},
  {key = 'h',      mods = 'NONE',        action = act.CopyMode('MoveLeft')},
  {key = 'j',      mods = 'NONE',        action = act.CopyMode('MoveDown')},
  {key = 'k',      mods = 'NONE',        action = act.CopyMode('MoveUp')},
  {key = 'l',      mods = 'NONE',        action = act.CopyMode('MoveRight')},
  {key = 'e',      mods = 'NONE',        action = act.CopyMode('MoveForwardWord')},
  {key = 'b',      mods = 'NONE',        action = act.CopyMode('MoveBackwardWord')},
  {key = '$',      mods = 'NONE',        action = act.CopyMode('MoveToEndOfLineContent')},
  {key = '0',      mods = 'NONE',        action = act.CopyMode('MoveToStartOfLine')},
}

M.normal_mode = {
  {key = '|',     mods = 'SUPER|SHIFT', action = 'ActivateCopyMode'},
  {key = 'Enter', mods = 'SUPER',       action = 'QuickSelect'},
  {key = '-',     mods = 'SUPER',       action = 'DecreaseFontSize'},
  {key = '-',     mods = 'SUPER|SHIFT', action = 'IncreaseFontSize'},
  {key = '0',     mods = 'SUPER',       action = 'ResetFontSize'},
  {key = '0',     mods = 'SUPER|SHIFT', action = 'ResetFontSize'},
  {key = ']',     mods = 'SUPER|SHIFT', action = 'ShowDebugOverlay'},
  {key = 'm',     mods = 'SUPER|SHIFT', action = 'ShowLauncher'},
  {key = 'z',     mods = 'SUPER',       action = 'TogglePaneZoomState'},
  {key = 'f',     mods = 'SUPER',       action = act.Search({CaseInSensitiveString = ''})},
  {key = 'c',     mods = 'SUPER',       action = act.CopyTo('Clipboard')},
  {key = 'p',     mods = 'SUPER|SHIFT', action = act.ActivateCommandPalette},
  {key = 'v',     mods = 'SUPER',       action = act.PasteFrom('Clipboard')},
  {key = 'l',     mods = 'CTRL|SHIFT',  action = clearScrollbackAndSendClearKey},
  {key = 'u',     mods = 'CTRL|SUPER',  action = act.AttachDomain('unix')},

  {key = 't', mods = 'SUPER',       action = act.SpawnTab('CurrentPaneDomain')},
  {key = 'd', mods = 'SUPER',       action = act.SplitHorizontal({domain = 'CurrentPaneDomain'})},
  {key = 'd', mods = 'SUPER|SHIFT', action = act.SplitVertical({domain = 'CurrentPaneDomain'})},
  {key = 's', mods = 'SUPER|SHIFT', action = act.SplitHorizontal({domain = 'CurrentPaneDomain'})},
  {key = 's', mods = 'SUPER',       action = act.SplitVertical({domain = 'CurrentPaneDomain'})},
  {key = 'w', mods = 'SUPER',       action = act.CloseCurrentTab({confirm = true})},

  {key = 'h', mods = 'SUPER',       action = act.ActivatePaneDirection('Left')},
  {key = 'l', mods = 'SUPER',       action = act.ActivatePaneDirection('Right')},
  {key = 'k', mods = 'SUPER',       action = act.ActivatePaneDirection('Up')},
  {key = 'j', mods = 'SUPER',       action = act.ActivatePaneDirection('Down')},
  {key = 'h', mods = 'SUPER|SHIFT', action = act.AdjustPaneSize({'Left', 3})},
  {key = 'l', mods = 'SUPER|SHIFT', action = act.AdjustPaneSize({'Right', 3})},
  {key = 'k', mods = 'SUPER|SHIFT', action = act.AdjustPaneSize({'Up', 1})},
  {key = 'j', mods = 'SUPER|SHIFT', action = act.AdjustPaneSize({'Down', 1})},

  {key = '1', mods = 'SUPER',      action = act.ActivateTab(0)},
  {key = '2', mods = 'SUPER',      action = act.ActivateTab(1)},
  {key = '3', mods = 'SUPER',      action = act.ActivateTab(2)},
  {key = '4', mods = 'SUPER',      action = act.ActivateTab(3)},
  {key = '5', mods = 'SUPER',      action = act.ActivateTab(4)},
  {key = '6', mods = 'SUPER',      action = act.ActivateTab(5)},
  {key = '1', mods = 'SUPER|CTRL', action = act.MoveTab(0)},
  {key = '2', mods = 'SUPER|CTRL', action = act.MoveTab(1)},
  {key = '3', mods = 'SUPER|CTRL', action = act.MoveTab(2)},
  {key = '4', mods = 'SUPER|CTRL', action = act.MoveTab(3)},
  {key = '5', mods = 'SUPER|CTRL', action = act.MoveTab(4)},
  {key = '6', mods = 'SUPER|CTRL', action = act.MoveTab(5)},
}

M.search_mode = {
  {key = 'Escape', mods = 'NONE',        action = act.CopyMode('Close')},
  {key = 'Enter',  mods = 'NONE',        action = 'ActivateCopyMode'},
  {key = 'n',      mods = 'SUPER',       action = act.CopyMode('PriorMatch')},
  {key = 'n',      mods = 'SUPER|SHIFT', action = act.CopyMode('NextMatch')},
  {key = 't',      mods = 'SUPER',       action = act.CopyMode('CycleMatchType')},
  {key = 'l',      mods = 'SUPER',       action = act.CopyMode('ClearPattern')},
}

return M

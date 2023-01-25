local wezterm = require 'wezterm'
local act = wezterm.action

local clearScrollbackAndSendClearKey = act.Multiple {
  act.ClearScrollback 'ScrollbackAndViewport',
  act.SendString '\x03',
  act.SendString 'clear;reset',
  act.SendString '\x0d',
}

local keymap = {
  {key = '[',     mods = 'SUPER',       action = 'ActivateCopyMode'},
  {key = 'Enter', mods = 'SUPER',       action = 'QuickSelect'},
  {key = '-',     mods = 'SUPER',       action = 'DecreaseFontSize'},
  {key = '_',     mods = 'SUPER|SHIFT', action = 'IncreaseFontSize'},
  {key = '0',     mods = 'SUPER',       action = 'ResetFontSize'},
  {key = ']',     mods = 'SUPER',       action = 'ShowDebugOverlay'},
  {key = 'm',     mods = 'SUPER',       action = 'ShowLauncher'},
  {key = 'Enter', mods = 'ALT',         action = 'ToggleFullScreen'},
  {key = 'z',     mods = 'SUPER',       action = 'TogglePaneZoomState'},
  {key = 'f',     mods = 'SUPER',       action = act.Search('CurrentSelectionOrEmptyString')},
  {key = 'c',     mods = 'SUPER',       action = act.CopyTo('Clipboard')},
  {key = 'v',     mods = 'SUPER',       action = act.PasteFrom('Clipboard')},
  {key = 'l',     mods = 'CTRL|SHIFT',  action = clearScrollbackAndSendClearKey},
  {key = 'u',     mods = 'CTRL|SUPER',  action = act.AttachDomain('unix')},

  {key = 't', mods = 'SUPER',       action = act.SpawnTab 'CurrentPaneDomain'},
  {key = 't', mods = 'SUPER|SHIFT', action = act.SpawnTab 'DefaultDomain'},
  {key = 'd', mods = 'SUPER',       action = act.SplitHorizontal {domain = 'CurrentPaneDomain'}},
  {key = 'd', mods = 'SUPER|SHIFT', action = act.SplitVertical {domain = 'CurrentPaneDomain'}},
  {key = 'w', mods = 'SUPER',       action = act.CloseCurrentTab {confirm = true}},

  {key = 'h', mods = 'SUPER',       action = act.ActivatePaneDirection 'Left'},
  {key = 'l', mods = 'SUPER',       action = act.ActivatePaneDirection 'Right'},
  {key = 'k', mods = 'SUPER',       action = act.ActivatePaneDirection 'Up'},
  {key = 'j', mods = 'SUPER',       action = act.ActivatePaneDirection 'Down'},
  {key = 'h', mods = 'SUPER|SHIFT', action = act.AdjustPaneSize {'Left', 3}},
  {key = 'l', mods = 'SUPER|SHIFT', action = act.AdjustPaneSize {'Right', 3}},
  {key = 'k', mods = 'SUPER|SHIFT', action = act.AdjustPaneSize {'Up', 1}},
  {key = 'j', mods = 'SUPER|SHIFT', action = act.AdjustPaneSize {'Down', 1}},

  {key = '1', mods = 'SUPER',       action = act.ActivateTab(0)},
  {key = '2', mods = 'SUPER',       action = act.ActivateTab(1)},
  {key = '3', mods = 'SUPER',       action = act.ActivateTab(2)},
  {key = '4', mods = 'SUPER',       action = act.ActivateTab(3)},
  {key = '5', mods = 'SUPER',       action = act.ActivateTab(4)},
  {key = '6', mods = 'SUPER',       action = act.ActivateTab(5)},

  {key = '1', mods = 'SUPER|CTRL', action = act.MoveTab(0)},
  {key = '2', mods = 'SUPER|CTRL', action = act.MoveTab(1)},
  {key = '3', mods = 'SUPER|CTRL', action = act.MoveTab(2)},
  {key = '4', mods = 'SUPER|CTRL', action = act.MoveTab(3)},
  {key = '5', mods = 'SUPER|CTRL', action = act.MoveTab(4)},
  {key = '6', mods = 'SUPER|CTRL', action = act.MoveTab(5)},
};

return keymap;

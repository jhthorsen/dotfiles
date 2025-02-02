local wezterm = require 'wezterm'
local key_tables = require 'user_key_tables'
local mouse_bindings = require 'user_mouse_bindings'
local theme_kanagawa = require 'user_theme_kanagawa'

wezterm.on('gui-startup', function()
 local _, _, window = wezterm.mux.spawn_window({})
 window:gui_window():maximize()
end)

return {
  audible_bell = 'Disabled',
  debug_key_events = false,
  enable_scroll_bar = false,
  enable_tab_bar = false,
  hide_tab_bar_if_only_one_tab = true,
  inactive_pane_hsb = {brightness = 0.75, saturation = 0.85},
  native_macos_fullscreen_mode = false,
  scrollback_lines = 10000,
  window_close_confirmation = 'AlwaysPrompt',
  window_padding = {top = 6, right = 6, bottom = 0, left = 6},

  colors = theme_kanagawa,
  font_size = 12,
  line_height = 1.3,
  font = wezterm.font_with_fallback({
    {family = 'Hack Nerd Font'},
    {family = 'JetBrains Mono'},
  }),

  automatically_reload_config = true,
  disable_default_key_bindings = true,
  use_dead_keys = false,
  key_tables = {copy_mode = key_tables.copy_mode, search_mode = key_tables.search_mode},
  keys = key_tables.normal_mode,
  mouse_bindings = mouse_bindings,
}

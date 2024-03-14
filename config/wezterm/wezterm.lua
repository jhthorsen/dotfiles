local wezterm = require 'wezterm'
local key_tables = require 'user_key_tables'
local mouse_bindings = require 'user_mouse_bindings'
local theme_kanagawa = require 'user_theme_kanagawa'

return {
  default_gui_startup_args = {'connect', 'unix'},
  unix_domains = {{name = 'unix'}},

  audible_bell = 'Disabled',
  enable_scroll_bar = false,
  enable_tab_bar = false,
  hide_tab_bar_if_only_one_tab = true,
  native_macos_fullscreen_mode = false,
  scroll_to_bottom_on_input = true,
  scrollback_lines = 10000,
  window_background_opacity = 0.96,
  window_padding = {top = 3, right = 3, bottom = 3, left = 3},

  colors = theme_kanagawa,
  font_size = 12,
  line_height = 1.3,
  font = wezterm.font_with_fallback({
    {family = 'Hack Nerd Font'},
    {family = 'JetBrains Mono'},
  }),

  automatically_reload_config = true,
  check_for_updates = false,
  disable_default_key_bindings = true,
  key_tables = {copy_mode = key_tables.copy_mode, search_mode = key_tables.search_mode},
  keys = key_tables.normal_mode,
  mouse_bindings = mouse_bindings,
}

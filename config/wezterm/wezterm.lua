local wezterm = require 'wezterm'
local keymap = require 'keymap'
local key_table_copy_mode = require 'key_table_copy_mode'
local key_table_search_mode = require 'key_table_search_mode'
-- local launch_menu = require 'private_launch_menu'
local mouse_bindings = require 'mouse_bindings'
-- local ssh_domains = require 'ssh_domains'
local theme_kanagawa = require 'theme_kanagawa'

return {
  -- launch_menu = launch_menu,
  -- ssh_domains = ssh_domains,
  unix_domains = {
    {
      name = 'unix',
      -- local_echo_threshold_ms = 1000,
    },
  },

  -- debug_key_events = true,
  -- leader = { key = ' ', mods = 'CTRL' },
  -- send_composed_key_when_left_alt_is_pressed = false,
  -- send_composed_key_when_right_alt_is_pressed = true,

  colors = theme_kanagawa,
  -- force_reverse_video_cursor = true,
  font = wezterm.font_with_fallback {
    {family = 'Hack'},
    {family = 'JetBrains Mono'},
  },
  -- harfbuzz_features = {'calt=0', 'clig=1', 'liga=1'},
  font_size = 12,
  line_height = 1.3,
  window_background_opacity = 0.96,

  -- adjust_window_size_when_changing_font_size = true,
  audible_bell = 'Disabled',
  automatically_reload_config = true,
  check_for_updates = false,
  default_gui_startup_args = {'connect', 'unix'},
  disable_default_key_bindings = true,
  exit_behavior = 'Close',
  keys = keymap,
  key_tables = {copy_mode = key_table_copy_mode, search_mode = key_table_search_mode},
  mouse_bindings = mouse_bindings,
  scroll_to_bottom_on_input = true,
  scrollback_lines = 10000,

  enable_scroll_bar = false,
  enable_tab_bar = false,
  hide_tab_bar_if_only_one_tab = true,
  native_macos_fullscreen_mode = false,
  window_padding = {top = 3, right = 3, bottom = 3, left = 3},
}

local wezterm = require("wezterm")
local key_tables = require("user_key_tables")
local mouse_bindings = require("user_mouse_bindings")
local theme_kanagawa = require("user_theme_kanagawa")
local config = wezterm.config_builder()

wezterm.on("update-status", require("resize_window_on_scale_change"))

config.audible_bell = "Disabled"
config.debug_key_events = false
config.enable_scroll_bar = false
config.enable_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.inactive_pane_hsb = { brightness = 0.75, saturation = 0.85 }
config.window_decorations = "RESIZE"
config.native_macos_fullscreen_mode = false
config.scrollback_lines = 30000
config.window_close_confirmation = "AlwaysPrompt"
config.window_padding = { top = 12, right = 14, bottom = 14, left = 14 }

config.colors = theme_kanagawa
config.font_size = 12.2
config.line_height = 1.2
config.font = wezterm.font_with_fallback({
  { family = "Hack Nerd Font" },
  { family = "JetBrains Mono" },
})

config.automatically_reload_config = true
config.disable_default_key_bindings = true
config.use_dead_keys = false
config.key_tables = { copy_mode = key_tables.copy_mode, search_mode = key_tables.search_mode }
config.keys = key_tables.normal_mode
config.mouse_bindings = mouse_bindings

return config

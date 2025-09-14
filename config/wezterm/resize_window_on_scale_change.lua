local wezterm = require("wezterm")
local current_screen_scale = 0 -- 1 = external monitor, 2 = retina monitor

return function(window)
  -- Check if we have moved the window from a retina to a non-retina screen or vice-versa
  local screen = wezterm.gui.screens().active
  if window:is_focused() == false then return end
  if screen.scale == current_screen_scale then return end
  current_screen_scale = screen.scale

  local height = screen.height
  local width = screen.width
  local overrides = window:get_config_overrides() or {}

  if screen.scale == 2 then
    overrides.dpi = 144
    overrides.font_size = 12
    height = height
    width = width
  else
    overrides.dpi = 100
    overrides.font_size = 9
    height = height * 0.8
    width = width > 2000 and 2000 or width * 0.9
  end

  -- wezterm.log_info(overrides)
  -- wezterm.log_info(wezterm.gui.screens())
  -- window:toast_notification("WezTerm", width .. "x" .. height .. ", scale=" .. screen.scale, nil, 3000)
  window:set_config_overrides(overrides)

  wezterm.time.call_after(0.25, function()
    height = math.floor(height)
    width = math.floor(width)
    window:set_inner_size(width, height)

    if screen.width == width then
      window:maximize()
    else
      window:set_position(screen.width - width - 40, math.floor((screen.height - height) / 2))
    end
  end)
end

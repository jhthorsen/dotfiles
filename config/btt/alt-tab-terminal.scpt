global frontApp, frontAppName, windowTitle

set windowTitle to ""
tell application "System Events"
  set frontApp to first application process whose frontmost is true
  set frontAppName to name of frontApp
  tell process frontAppName
    tell (1st window whose value of attribute "AXMain" is true)
      set windowTitle to value of attribute "AXTitle"
    end tell
  end tell

  if frontAppName contains "wezterm-gui" then
    tell application "System Events"
      key down command
      keystroke tab
      key up command
    end tell
  else
    tell application "WezTerm"
      activate
    end tell
  end if
end tell

return {frontAppName, windowTitle}

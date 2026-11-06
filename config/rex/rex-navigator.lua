--
-- rex-navigator.lua
--
-- The Rex side of rex-navigator.nvim. Load it from ~/.config/rex/init.lua:
--
--   require("rex-navigator").setup()
--
-- ctrl-h/j/k/l moves between Rex panes, except when Vim or Neovim is the
-- focused program. Then the key goes through to it, and the Neovim side of the
-- plugin moves between its own splits, handing back to Rex at the edge.
--

local M = {}

local defaults = {
  -- physical keys, so the binding doesn't depend on the keyboard layout
  keys = {
    left = 'ctrl+[KeyH]',
    down = 'ctrl+[KeyJ]',
    up = 'ctrl+[KeyK]',
    right = 'ctrl+[KeyL]',
  },
  -- Lua patterns matched against the focused program's name
  programs = { '^n?vim$', '^view$', '^n?vimdiff$' },
  -- continue from the opposite edge when no pane lies that way
  wrap = false,
}

local function merge(base, overrides)
  local result = {}
  for k, v in pairs(base) do
    result[k] = v
  end
  for k, v in pairs(overrides or {}) do
    if type(v) == 'table' and type(result[k]) == 'table' and #v == 0 then
      result[k] = merge(result[k], v)
    else
      result[k] = v
    end
  end
  return result
end

local function basename(path)
  return (path or ''):match('[^/]+$') or ''
end

function M.is_vim(programs)
  local ok, process = pcall(rex.block.call, 'com.superlogical.terminal', 'process', {})
  local foreground = ok and process and process.foreground
  if not foreground then
    return false
  end

  for _, name in ipairs({ foreground.name or '', basename(foreground.argv0) }) do
    for _, pattern in ipairs(programs) do
      if name:match(pattern) then
        return true
      end
    end
  end
  return false
end

function M.setup(opts)
  local config = merge(defaults, opts)

  for direction, key in pairs(config.keys) do
    rex.bind(key, function(ctx)
      if M.is_vim(config.programs) then
        return false -- let the key through to Vim
      end

      -- the server method, the app's pane.focus.* actions always wrap
      rex.call('session.focus_direction', {
        session_id = ctx.session_id,
        direction = direction,
        wrap = config.wrap,
      })
      return true
    end)
  end
end

return M

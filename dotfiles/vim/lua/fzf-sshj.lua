if not pcall(require, "fzf") then
  return
end

local config = require "fzf-lua.config"
local fzf_helpers = require "fzf.helpers"
local core = require "fzf-lua.core"
local utils = require "fzf-lua.utils"

local M = {}

M.files = function(opts)
  opts = config.normalize_opts(opts, config.globals.files)
  opts.previewer = false

  opts.fzf_fn = fzf_helpers.cmd_line_transformer('cat ' .. os.getenv('HOME') .. '/.local/share/sshj/cache/' .. os.getenv('SSHJ_TARGET_HOST') .. '.files',
    function(x)
      return 'scp://' .. os.getenv('SSHJ_TARGET_HOST') .. '/' .. x
    end)

  -- print(vim.inspect(opts))
  return core.fzf_files(opts)
end

return M

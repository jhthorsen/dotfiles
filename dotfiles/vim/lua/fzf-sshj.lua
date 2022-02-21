if not pcall(require, "fzf") then
  return
end

local config = require "fzf-lua.config"
local fzf_helpers = require "fzf.helpers"
local core = require "fzf-lua.core"

local M = {}

M.files = function(opts)
  opts = config.normalize_opts(opts, config.globals.files)
  opts.previewer = false

  opts.actions['default'] = function(selected, opts)
    vim.cmd("e " .. selected[1])
  end

  opts.actions['ctrl-t'] = function(selected, opts)
    vim.cmd("tabnew " .. selected[1])
  end

  local sshj_cache_file = string.format('%s/.local/share/sshj/cache/%s.files', os.getenv('HOME'), os.getenv('SSHJ_TARGET_HOST'))
  opts.fzf_fn = fzf_helpers.cmd_line_transformer('cat ' .. sshj_cache_file, function(x)
    return 'scp://' .. os.getenv('SSHJ_TARGET_HOST') .. '/' .. x
  end)

  return core.fzf_files(opts)
end

return M

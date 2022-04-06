local uv = vim.loop

function syncFileToRemoteHost()
  local remote_dir = os.getenv('NVIM_REMOTE_DIR')
  local remote_host = os.getenv('NVIM_REMOTE_HOST')

  if remote_dir ~= nil and remote_dir ~= nil then
    local file = vim.api.nvim_buf_get_name(0)
    local projects_dir = file
    local project_name
    while #projects_dir > 1 do
      projects_dir, project_name = string.match(projects_dir, "^(.-)[\\/]?([^\\/]*)$")
      local stat = uv.fs_stat(string.format('%s/%s/.git', projects_dir, project_name))
      if stat and stat.type == 'directory' then
        local project_file = string.sub(file, 1 + string.len(string.format('%s/%s/', projects_dir, project_name)))
        local cmd = string.format('scp %s %s:%s/%s/%s', file, remote_host, remote_dir, project_name, project_file)
        -- print(cmd)
        os.execute(cmd)
        break
      end
    end
  end
end

vim.cmd('autocmd BufWritePost * lua syncFileToRemoteHost()')

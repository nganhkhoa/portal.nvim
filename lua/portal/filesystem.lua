M = {}

function M.list_files_folder(opts)
  local lines = { "../", }
  local entries = vim.fn.readdir(opts.path, true)
  for i, entry in ipairs(entries) do
    local full_path = opts.path .. '/' .. entry
    if vim.fn.isdirectory(full_path) == 1 then
      table.insert(lines, entry .. '/')
    else
      table.insert(lines, entry)
    end
  end
  return lines
end

function M.try_create(opts)
  if opts.is_file then
    vim.fn.writefile({}, opts.path)
  else
    vim.fn.mkdir(opts.path, "p")
  end
end

return M

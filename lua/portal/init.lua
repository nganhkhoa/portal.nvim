local M = {}

M.config = {
  display_mode = "full", -- "full" or "float"
  show_hidden = true,
  show_git_ignore = true,
  with_icon = false,
  binds = {
    open = '<CR>',
    quick_open = 'l',
    move_to_parent = 'h',
    quit = 'q',
    new_file = 'i',
    new_folder = 'o',
    rename = 'r',
    refresh = 'R',
    toggle_hidden = '.',
  }
}

function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})
end

function M.open_window(bufnr, title)
  local mode = M.config.display_mode

  if mode == "float" then
    local width = math.floor(vim.o.columns * 0.8)
    local height = math.floor(vim.o.lines * 0.8)
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)

    vim.api.nvim_open_win(bufnr, true, {
      relative = 'editor',
      row = row,
      col = col,
      width = width,
      height = height,
      border = 'single',
      title = title,
    })
  else
    vim.api.nvim_set_current_buf(bufnr)
    if title then
        -- Optionally set the buffer's name for clarity
        -- vim.api.nvim_buf_set_name(bufnr, '[ ' .. title .. ' ]')
    end
  end
end

return M

Window = {}
Window.__index = Window

-- the logic behind window is to only use scratch and remove it as
-- soon as we exit the browser
-- each browser has its own state, tied by the buffer local vars

function Window:new(register_bindings, state)
  local instance = {}
  setmetatable(instance, self)

  instance.state = state
  instance.bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(instance.bufnr, 'buftype', 'nofile')
  vim.api.nvim_buf_set_option(instance.bufnr, 'modifiable', false)
  vim.api.nvim_buf_set_option(instance.bufnr, 'readonly', true)

  register_bindings(instance)
  return instance
end

function Window:update_lines(lines)
  -- update the buffer with list of line
  vim.api.nvim_buf_set_option(self.bufnr, 'modifiable', true)
  vim.api.nvim_buf_set_option(self.bufnr, 'readonly', false)
  vim.api.nvim_buf_set_lines(self.bufnr, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(self.bufnr, 'modifiable', false)
  vim.api.nvim_buf_set_option(self.bufnr, 'readonly', true)
end

function Window:set_cursor(at)
  vim.api.nvim_win_set_cursor(0, {at, 0})
end

function Window:open()
  -- local mode = M.config.display_mode
  local mode = "full"
  vim.api.nvim_set_current_buf(self.bufnr)
  return nil

  -- local width = math.floor(vim.o.columns * 0.8)
  -- local height = math.floor(vim.o.lines * 0.8)
  -- local row = math.floor((vim.o.lines - height) / 2)
  -- local col = math.floor((vim.o.columns - width) / 2)

  -- vim.api.nvim_open_win(bufnr, true, {
  --   relative = 'editor',
  --   row = row,
  --   col = col,
  --   width = width,
  --   height = height,
  --   border = 'single',
  --   title = title,
  -- })
end

function Window:close()
  if vim.api.nvim_buf_is_valid(self.bufnr) then
    vim.api.nvim_buf_delete(self.bufnr, { force = true })
    self.bufnr = nil
  end
end

return Window

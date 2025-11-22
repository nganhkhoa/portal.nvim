M = {}
local plugin = require('portal')
local winmgr = require('portal.window')

local function refresh(browser)
  local lines = {}
  local buffers = vim.fn.getbufinfo({ buflisted = 1 })
  table.sort(buffers, function(a, b)
    return a.lastused > b.lastused
  end)
  for _, buffer in ipairs(buffers) do
    if buffer.name == "" then
      table.insert(lines, buffer.bufnr .. " - [NoName]")
    else
      table.insert(lines, buffer.bufnr .. " - " .. buffer.name)
    end
  end
  browser:update_lines(lines)
end

local function get_buffer_at_cursor()
  local line = vim.api.nvim_get_current_line()
  local parts = vim.split(line, "-", { trimempty = true })
  return tonumber(parts[1])
end

local function delete_buffer(browser)
  local bufnr = get_buffer_at_cursor()
  vim.api.nvim_buf_delete(bufnr, { force = true })
  refresh(browser)
end

local function navigate_entry(browser)
  local bufnr = get_buffer_at_cursor()
  vim.api.nvim_set_current_buf(bufnr)
end

local function quit_browser(browser)
  vim.api.nvim_set_current_buf(browser.state.last_open)
  browser:close()
end

local function register_bindings(browser)
  buffer_option = { buffer = browser.bufnr, silent = true }
  vim.keymap.set('n', '<CR>', function() navigate_entry(browser) end, buffer_option)
  vim.keymap.set('n', 'd', function() delete_buffer(browser) end, buffer_option)
  vim.keymap.set('n', 'q', function() quit_browser(browser) end, buffer_option)
end

function M.open()
  -- this function can still be called when already in the browser
  -- consider disable that for the browser ?
  state = {}
  state.last_open = vim.api.nvim_get_current_buf()

  -- this design lets us share code between the file browser and buffer browser
  -- however, we need a better way to handle state whenever content changes
  -- hook is good, when state are changed, browser is automatically updated

  -- bindings are kept to this specific browser
  -- when the browser dies, all data belongs to the browser freed
  -- bind a state to the browser window
  local browser = winmgr:new(register_bindings, state)
  browser:open()
  refresh(browser)
end

return M

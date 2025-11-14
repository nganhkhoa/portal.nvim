local M = {}
local plugin = require('portal')
local winmgr = require('portal.window')
local filesystem = require('portal.filesystem')

local function get_initial_path()
  local bufnr = vim.api.nvim_get_current_buf()
  local current_file = vim.api.nvim_buf_get_name(bufnr)

  if current_file == '' or vim.fn.filereadable(current_file) == 0 then
    return vim.fn.getcwd()
  else
    local dir_path = vim.fn.fnamemodify(current_file, ':p:h')
    return vim.fn.resolve(dir_path)
  end
end

local function refresh(browser)
  local lines = filesystem.list_files_folder({
    path = browser.state.current_path,
    show_hidden = browser.state.show_hidden,
    show_git_ignore = browser.state.show_git_ignore,
  })
  -- add icons
  browser:update_lines(lines)
  -- browser:set_cursor()
end

local function navigate_entry(browser)
  local state = browser.state

  local line = vim.api.nvim_get_current_line()
  local item_name = line:gsub('/', '')
  local full_path = state.current_path .. '/' .. item_name

  local enter_folder = item_name == '..' or vim.fn.isdirectory(full_path) == 1

  if enter_folder then
    state.current_path = vim.fn.fnamemodify(full_path, ':p')
    browser.state = state -- update the state
    refresh(browser)
  else
    -- exiting the browser will kill the browser
    vim.cmd('edit ' .. full_path)
  end
end

local function move_to_parent(browser)
  browser.state.current_path = vim.fn.fnamemodify(browser.state.current_path, ':h')
  refresh(browser)
end

local function quit_browser(browser)
  vim.api.nvim_set_current_buf(browser.state.last_open)
  browser:close()
end

local function new_file(browser)
  local filename = vim.fn.input("Enter the new file name: ")
  if filename == nil or filename == "" then
    return
  end
  filesystem.try_create({
    is_file = true,
    path = filename,
  })
  refresh(browser)
end

local function new_folder(browser)
  local foldername = vim.fn.input("Enter the new folder name: ")
  if foldername == nil or foldername == "" then
    return
  end
  filesystem.try_create({
    is_file = false,
    path = foldername,
  })
  refresh(browser)
end

local function rename(browser)
end

local function toggle_hidden(browser)
  local show_hidden = browser.state.show_hidden
  browser.state.show_hidden = not show_hidden
  refresh(browser)
end

local function register_bindings(browser)
  buffer_option = { buffer = browser.bufnr, silent = true }
  vim.keymap.set('n', '<CR>', function() navigate_entry(browser) end, buffer_option)
  vim.keymap.set('n', 'l', function() navigate_entry(browser) end, buffer_option)
  vim.keymap.set('n', 'h', function() move_to_parent(browser) end, buffer_option)
  vim.keymap.set('n', 'q', function() quit_browser(browser) end, buffer_option)
  vim.keymap.set('n', 'i', function() new_file(browser) end, buffer_option)
  vim.keymap.set('n', 'o', function() new_folder(browser) end, buffer_option)
  vim.keymap.set('n', 'r', function() rename(browser) end, buffer_option)
  vim.keymap.set('n', '.', function() toggle_hidden(browser) end, buffer_option)
  vim.keymap.set('n', 'R', function() refresh(browser) end, buffer_option)
end

function M.open()
  -- this function can still be called when already in the browser
  -- consider disable that for the browser ?
  state = {}
  state.current_path = get_initial_path()
  state.last_open = vim.api.nvim_get_current_buf()
  state.show_hidden = true
  state.show_git_ignore = true

  current_file = vim.api.nvim_buf_get_name(state.last_open)
  if vim.fn.filereadable(current_file) == 1 then
    state.last_entry = vim.fn.fnamemodify(current_file, ':t')
  end

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

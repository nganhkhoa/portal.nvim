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
    local dir_path = vim.fs.dirname(current_file)
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

  -- set cursor when open from a file
  -- or moving from folder to folder
  local prev = browser.state.cursor_file
  if prev == nil then
    return
  end

  local cursor_idx = 1
  local current = browser.state.current_path
  -- print(current, vim.inspect(lines), prev)
  for i, path in ipairs(lines) do
    -- because of styling we put / for folders in lines
    local entry = vim.fs.joinpath(current, path):gsub('/$', '')
    if entry == prev then
      cursor_idx = i
      break
    end
  end
  browser:set_cursor(cursor_idx)
end

local function move_to_parent(browser)
  local current = browser.state.current_path:gsub('/$', '')
  browser.state.cursor_file = current
  browser.state.current_path = vim.fs.dirname(current)
  refresh(browser)
end

local function navigate_entry(browser)
  local state = browser.state
  local line = vim.api.nvim_get_current_line()
  local item_name = line:gsub('/$', '')

  if item_name == '..' then
    move_to_parent(browser)
    return
  end

  browser.state.cursor_file = state.current_path
  local full_path = vim.fs.joinpath(state.current_path, item_name)

  -- print('navigate entry from ' .. state.current_path .. ' to ' .. item_name .. ' -> ' .. full_path)

  local enter_folder = vim.fn.isdirectory(full_path) == 1
  if enter_folder then
    state.current_path = full_path
    browser.state = state
    refresh(browser)
  else
    -- exiting the browser will kill the browser
    vim.cmd('edit ' .. full_path)
  end
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
    path = vim.fs.joinpath(browser.state.current_path, filename),
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
    path = vim.fs.joinpath(browser.state.current_path, foldername),
  })
  refresh(browser)
end

local function rename(browser)
  local line = vim.api.nvim_get_current_line()
  local file = line:gsub('/$', '')

  local newname = vim.fn.input("Rename file " .. file .. ' into? ')
  if newname == nil or newname == "" then
    return
  end

  local fullpath_old = vim.fs.joinpath(browser.state.current_path, file)
  local fullpath_new = vim.fs.joinpath(browser.state.current_path, newname)
  os.rename(fullpath_old, fullpath_new)
  refresh(browser)
end

local function delete(browser)
  local line = vim.api.nvim_get_current_line()
  local file = line:gsub('/$', '')

  local fullpath = vim.fs.joinpath(browser.state.current_path, file)
  local confirm = vim.fn.input("Deleting file " .. fullpath .. '? (y/N) ')
  if confirm == nil or confirm ~= "y" then
    return
  end
  os.remove(fullpath)
  refresh(browser)
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
  vim.keymap.set('n', 'd', function() delete(browser) end, buffer_option)
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

  state.cursor_file = nil

  current_file = vim.api.nvim_buf_get_name(state.last_open)
  if vim.fn.filereadable(current_file) == 1 then
    state.cursor_file = current_file
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

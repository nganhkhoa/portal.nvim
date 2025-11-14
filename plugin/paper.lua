vim.api.nvim_create_user_command(
  'BrowseFile',
  function()
    require('portal.file_browser').open()
  end,
  { desc = 'Browse files in the current directory' }
)

vim.api.nvim_create_user_command(
  'BrowseBuffer',
  function()
    require('portal.buffer_browser').open()
  end,
  { desc = 'List and switch between open buffers' }
)

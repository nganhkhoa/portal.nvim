# Portal

A Neovim Lua plugin for managing your files and buffers. This plugin aims to be minimal, no-bloat browser for files and current opened buffers.

This plugin is inspired by [vaffle](https://github.com/cocopon/vaffle.vim) and [buffergator](https://github.com/jeetsukumaran/vim-buffergator/tree/master). I had been using these plugins for years because of their minimalistic. However, these plugins are no long maintained, written in Vimlang, and contains some minor bugs. I write this plugin as my first Neovim plugin, which is a step up from being a normal Neovim user to a vim plugin writer (after ~10 years lol).


## Setup

The plugin provides two commands for mapping. However, Lua api is usable as well.

```lua
nvim.set_keymap("n", "<leader>dd", ":PortalFile<CR>", {noremap = true, silent = true})
nvim.set_keymap("n", "<leader>b", ":PortalBuffer<CR>", {noremap = true, silent = true})
```

```lua
nvim.set_keymap("n", "<leader>dd", ":lua require('portal.file_browser').open()<CR>", {noremap = true, silent = true})
nvim.set_keymap("n", "<leader>b", ":lua require('portal.buffer_browser').open()<CR>", {noremap = true, silent = true})
```

## Keybinds

TODO

## Features

Some basic ideas to implement in the future, but the goal of the plugin is still "keep it simple".

- [x] files browser
- [x] buffers browser
- [x] create files
- [x] create folders
- [x] delete buffer
- [ ] delete files
- [ ] delete folders
- [ ] move files and folders
- [ ] toggle hidden files
- [ ] toggle show git ignore files
- [ ] add colors
- [ ] open split
- [ ] open in new tab


Right now, this plugin only supports buffer-wide browser. I will include floating window, and sidebar mode for both file browser and buffer browser.

I run Neovim on main branch (v0.12), but the APIs used should be compatible with stable Neovim versions. Just make an issue if you want support for some lower Neovim versions.

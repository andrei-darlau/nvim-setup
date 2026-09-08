--[[

Entry point. Nothing lives here except the leader keys and the four requires
below -- see `lua/config/` for editor settings and `lua/plugins/` for plugins.

  lua/config/options.lua   vim.o settings, filetypes, diagnostics
  lua/config/keymaps.lua   keymaps that don't belong to a plugin
  lua/config/autocmds.lua  autocommands that don't belong to a plugin
  lua/config/lazy.lua      bootstraps lazy.nvim and imports lua/plugins/
  lua/plugins/*.lua        one file per plugin, each returning a lazy spec
  after/ftplugin/*.lua     per-filetype buffer options

See `:help lua-guide` and `:Lazy` .

--]]

-- Must happen before plugins load, or plugins pick up the wrong leader.
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Set to true if you have a Nerd Font installed and selected in the terminal.
vim.g.have_nerd_font = true

require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.lazy")

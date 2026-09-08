-- Buffer-local options for VHDL files. This is the idiomatic place for
-- per-filetype settings -- see `:help ftplugin`.

-- Neovim's builtin vhdl ftplugin sets this correctly on recent versions; this
-- is a guard for older ones and for buffers whose filetype came from
-- vim.filetype.add() in lua/config/options.lua.
if vim.bo.commentstring == "" then
	vim.bo.commentstring = "-- %s"
end

-- VHDL convention is 2-space indent. Delete these to keep the global 4.
vim.bo.shiftwidth = 2
vim.bo.tabstop = 2
vim.bo.expandtab = true

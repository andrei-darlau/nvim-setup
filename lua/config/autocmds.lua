-- [[ Autocommands ]]
-- Plugin-specific autocommands live with their plugin in lua/plugins/.
-- Per-filetype buffer options live in after/ftplugin/.
-- See `:help lua-guide-autocommands`

-- Briefly highlight text when you yank it
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})

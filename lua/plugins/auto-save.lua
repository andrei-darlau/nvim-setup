-- Write the buffer automatically after you stop typing
return {
	"okuuva/auto-save.nvim",
	opts = {
		enabled = true,
		-- Every write makes rust-analyzer kick off a `cargo check`. Much below
		-- ~1s and the checks queue up and cancel each other, so diagnostics
		-- never settle.
		debounce_delay = 1000,
		condition = function(buf)
			return vim.bo[buf].filetype ~= "" and vim.bo[buf].modifiable
		end,
	},
}

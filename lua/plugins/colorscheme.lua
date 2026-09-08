-- Colorscheme. `priority = 1000` loads it before everything else.
return {
	"folke/tokyonight.nvim",
	priority = 1000,
	config = function()
		---@diagnostic disable-next-line: missing-fields
		require("tokyonight").setup({
			styles = {
				comments = { italic = false },
			},
			-- These are global capture -> colour links, not per-language. VHDL and
			-- SystemVerilog pick them up as soon as the query files in
			-- after/queries/ assign the same capture names.
			on_highlights = function(hl, c)
				hl["@variable.parameter"] = { fg = c.orange }
				hl["@property"] = { fg = c.cyan }
				hl["@keyword.repeat"] = { fg = c.magenta } -- always/initial, process
				hl["@punctuation.bracket"] = { fg = c.teal } -- begin/end + ()[]{}
				hl["@keyword.edge"] = { fg = c.yellow } -- posedge/negedge, rising_edge/falling_edge
			end,
		})

		vim.cmd.colorscheme("tokyonight-night")
	end,
}

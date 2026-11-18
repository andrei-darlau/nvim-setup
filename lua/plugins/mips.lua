-- MIPS treesitter grammar. nvim-treesitter's `main` branch has no built-in
-- entry for it, so register it from a TSUpdate autocmd. lazy.nvim clones the
-- repo (lazy = true: it is never added to the runtimepath), and
-- nvim-treesitter builds the parser from that local checkout, which avoids
-- its GitHub tarball download. `init` always runs at startup, before
-- treesitter.lua's config installs parsers ("mips" is in its list).
return {
	"omeyenburg/tree-sitter-mips",
	lazy = true,
	init = function()
		vim.api.nvim_create_autocmd("User", {
			group = vim.api.nvim_create_augroup("custom-ts-parsers", { clear = true }),
			pattern = "TSUpdate",
			callback = function()
				require("nvim-treesitter.parsers").mips = {
					install_info = {
						path = vim.fn.stdpath("data") .. "/lazy/tree-sitter-mips",
						queries = "queries",
					},
				}
			end,
		})
	end,
}

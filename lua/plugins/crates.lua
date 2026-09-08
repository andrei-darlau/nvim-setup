-- Versions, features and docs for crates in Cargo.toml
return {
	"saecki/crates.nvim",
	ft = { "toml" },
	opts = {
		lsp = {
			enabled = true,
			actions = true,
			completion = true,
			hover = true,
		},
		completion = {
			crates = { enabled = true },
		},
	},
}

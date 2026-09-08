-- File explorer sidebar
return {
	"nvim-tree/nvim-tree.lua",
	version = "*",
	lazy = false,
	dependencies = { "nvim-tree/nvim-web-devicons" },
	keys = {
		{ "<leader>e", "<cmd>NvimTreeToggle<CR>", desc = "Toggle file [E]xplorer" },
		{ "<leader>E", "<cmd>NvimTreeFindFile<CR>", desc = "Reveal current file in [E]xplorer" },
	},
	opts = {
		view = {
			width = 30,
			side = "left",
		},
		renderer = {
			group_empty = true,
		},
		filters = {
			dotfiles = false,
		},
	},
}

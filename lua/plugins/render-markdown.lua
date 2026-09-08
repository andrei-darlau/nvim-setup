-- In-buffer rendering for markdown
return {
	"MeanderingProgrammer/render-markdown.nvim",
	dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
	ft = { "markdown" },
	keys = {
		{ "<leader>tp", "<cmd>RenderMarkdown toggle<CR>", ft = "markdown", desc = "[T]oggle Markdown [P]review" },
	},
	opts = {},
}

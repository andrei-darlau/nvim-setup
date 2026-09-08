-- Shows pending keybinds in a popup
return {
	"folke/which-key.nvim",
	event = "VimEnter",
	opts = {
		delay = 0,
		icons = { mappings = vim.g.have_nerd_font },

		-- Names for the leader-key prefixes. Add a line here whenever you add a
		-- new group of mappings.
		spec = {
			{ "<leader>s", group = "[S]earch", mode = { "n", "v" } },
			{ "<leader>t", group = "[T]oggle" },
			{ "<leader>d", group = "[D]ebug" },
			{ "<leader>r", group = "[R]ust" },
			-- { "<leader>h", group = "Git [H]unk", mode = { "n", "v" } },
		},
	},
}

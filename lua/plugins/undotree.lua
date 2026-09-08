-- Visualise the undo history
return {
	"mbbill/undotree",
	cmd = { "UndotreeToggle", "UndotreeShow" },
	keys = {
		{ "<leader>u", vim.cmd.UndotreeToggle, desc = "Toggle [U]ndo Tree" },
	},
}

-- Fuzzy finder over files, grep, LSP symbols, help tags and more.
-- See `:help telescope` and `:help telescope.builtin`
return {
	"nvim-telescope/telescope.nvim",
	event = "VimEnter",
	dependencies = {
		"nvim-lua/plenary.nvim",
		{
			"nvim-telescope/telescope-fzf-native.nvim",
			build = "make",
			cond = function()
				return vim.fn.executable("make") == 1
			end,
		},
		"nvim-telescope/telescope-ui-select.nvim",
		{ "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
	},
	config = function()
		require("telescope").setup({
			extensions = {
				["ui-select"] = { require("telescope.themes").get_dropdown() },
			},
		})

		pcall(require("telescope").load_extension, "fzf")
		pcall(require("telescope").load_extension, "ui-select")

		local builtin = require("telescope.builtin")
		local map = vim.keymap.set

		map("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
		map("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
		map("n", "<leader>sf", builtin.find_files, { desc = "[S]earch [F]iles" })
		map("n", "<leader>ss", builtin.builtin, { desc = "[S]earch [S]elect Telescope" })
		map({ "n", "v" }, "<leader>sw", builtin.grep_string, { desc = "[S]earch current [W]ord" })
		map("n", "<leader>sg", builtin.live_grep, { desc = "[S]earch by [G]rep" })
		map("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
		map("n", "<leader>sr", builtin.resume, { desc = "[S]earch [R]esume" })
		map("n", "<leader>sc", builtin.commands, { desc = "[S]earch [C]ommands" })
		map("n", "<leader>s.", builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
		map("n", "<leader><leader>", builtin.buffers, { desc = "[ ] Find existing buffers" })

		map("n", "<leader>/", function()
			builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
				winblend = 10,
				previewer = false,
			}))
		end, { desc = "[/] Fuzzily search in current buffer" })

		map("n", "<leader>s/", function()
			builtin.live_grep({
				grep_open_files = true,
				prompt_title = "Live Grep in Open Files",
			})
		end, { desc = "[S]earch [/] in Open Files" })

		map("n", "<leader>sn", function()
			builtin.find_files({ cwd = vim.fn.stdpath("config") })
		end, { desc = "[S]earch [N]eovim files" })

		-- LSP pickers. These override Neovim's built-in `gr*` mappings with the
		-- Telescope equivalents, so they are bound on attach and live here rather
		-- than in plugins/lsp.lua -- swapping pickers only touches this file.
		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("telescope-lsp-attach", { clear = true }),
			callback = function(event)
				local lsp_map = function(keys, func, desc)
					map("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
				end

				lsp_map("grr", builtin.lsp_references, "[G]oto [R]eferences")
				lsp_map("gri", builtin.lsp_implementations, "[G]oto [I]mplementation")
				lsp_map("grd", builtin.lsp_definitions, "[G]oto [D]efinition")
				lsp_map("grt", builtin.lsp_type_definitions, "[G]oto [T]ype Definition")
				lsp_map("gO", builtin.lsp_document_symbols, "Open Document Symbols")
				lsp_map("gW", builtin.lsp_dynamic_workspace_symbols, "Open Workspace Symbols")
			end,
		})
	end,
}

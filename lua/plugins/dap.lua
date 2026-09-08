-- Debug Adapter Protocol client and UI.
-- Rust debug configurations come from rustaceanvim (`:RustLsp debuggables`).
return {
	{
		"mfussenegger/nvim-dap",
		keys = {
			-- stylua: ignore start
			{ "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Debugger toggle [B]reakpoint" },
			{ "<leader>dd", function() require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: ")) end, desc = "Debugger set con[D]itional breakpoint" },
			{ "<leader>dc", function() require("dap").continue() end, desc = "Debugger [C]ontinue" },
			{ "<leader>dl", function() require("dap").step_into() end, desc = "Debugger step into" },
			{ "<leader>dj", function() require("dap").step_over() end, desc = "Debugger step over" },
			{ "<leader>dk", function() require("dap").step_out() end, desc = "Debugger step out" },
			{ "<leader>dr", function() require("dap").run_last() end, desc = "Debugger [R]un last" },
			{ "<leader>de", function() require("dap").terminate() end, desc = "Debugger t[E]rminate" },
			-- stylua: ignore end
		},
		config = function()
			local dap = require("dap")

			-- Open the UI on session start, close it on session end.
			--
			-- `dapui` is required inside the callbacks, not at the top of this
			-- function. nvim-dap-ui depends on nvim-dap, so requiring it here --
			-- while nvim-dap is still mid-load -- is a module loop. By the time a
			-- session actually starts, nvim-dap is loaded and the require is safe.
			dap.listeners.before.attach.dapui_config = function()
				require("dapui").open()
			end
			dap.listeners.before.launch.dapui_config = function()
				require("dapui").open()
			end
			dap.listeners.before.event_terminated.dapui_config = function()
				require("dapui").close()
			end
			dap.listeners.before.event_exited.dapui_config = function()
				require("dapui").close()
			end

			-- codelldb is installed by mason-tool-installer, see plugins/lsp.lua
			local extension_path = vim.fn.stdpath("data") .. "/mason/packages/codelldb/extension/"

			dap.adapters.codelldb = {
				type = "server",
				port = "${port}",
				executable = {
					command = extension_path .. "adapter/codelldb",
					args = { "--port", "${port}" },
				},
			}

			dap.configurations.cpp = {
				{
					name = "Launch file",
					type = "codelldb",
					request = "launch",
					program = function()
						return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
					end,
					args = function()
						local args_string = vim.fn.input("Arguments: ")
						return vim.split(args_string, " +")
					end,
					cwd = "${workspaceFolder}",
					stopOnEntry = false,
				},
			}

			dap.configurations.c = dap.configurations.cpp
		end,
	},

	{
		"rcarriga/nvim-dap-ui",
		dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
		opts = {},
	},
}

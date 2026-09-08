-- Rust tooling.
--
-- rustaceanvim owns the rust-analyzer client entirely. Do NOT also configure or
-- enable rust_analyzer through nvim-lspconfig or vim.lsp.enable() -- you end up
-- with two clients fighting over the same buffer.
--
-- Install rust-analyzer with `rustup component add rust-analyzer` rather than
-- Mason, so it always matches your toolchain.
return {
	"mrcjkb/rustaceanvim",
	version = "^6",
	-- rustaceanvim is already lazy internally and its README says not to
	-- lazy-load it. With `ft = "rust"` the plugin reads vim.g.rustaceanvim
	-- before a `config` function would run, so the settings below are ignored.
	-- That is also why they live in `init` rather than `config`.
	lazy = false,
	init = function()
		local mason_path = vim.fn.stdpath("data") .. "/mason/packages/codelldb/extension/"
		local codelldb_path = mason_path .. "adapter/codelldb"
		local liblldb_path = mason_path .. "lldb/lib/liblldb.so"

		local dap_cfg = nil
		if vim.uv.fs_stat(codelldb_path) then
			local ok, rustacean_config = pcall(require, "rustaceanvim.config")
			if ok then
				dap_cfg = {
					adapter = rustacean_config.get_codelldb_adapter(codelldb_path, liblldb_path),
				}
			end
		end

		vim.g.rustaceanvim = {
			server = {
				default_settings = {
					["rust-analyzer"] = {
						-- rust-analyzer has two diagnostic sources: native analysis,
						-- which updates on every keystroke, and `cargo check`, which
						-- only runs on save. The experimental native diagnostics give
						-- you type and name errors without waiting for cargo.
						diagnostics = {
							enable = true,
							experimental = { enable = true },
							styleLints = { enable = true },
						},

						-- `checkOnSave` is a boolean in the current schema; the command
						-- lives under `check.command`. The old
						-- `checkOnSave = { command = "clippy" }` form is silently ignored.
						checkOnSave = true,
						check = {
							command = "clippy",
							extraArgs = { "--no-deps" },
							allTargets = false,
						},

						cargo = {
							allFeatures = true,
							buildScripts = { enable = true },
							-- Give rust-analyzer its own target dir, otherwise its
							-- `cargo check` and any cargo command you run in a terminal
							-- block on the same target/ lock.
							targetDir = true, -- -> target/rust-analyzer
						},

						procMacro = {
							enable = true,
							ignored = {
								-- Common offenders that hang proc-macro expansion
								["async-trait"] = { "async_trait" },
								["napi-derive"] = { "napi" },
							},
						},

						files = {
							excludeDirs = { ".direnv", ".git", "target", "node_modules" },
						},

						inlayHints = {
							bindingModeHints = { enable = false },
							closureReturnTypeHints = { enable = "with_block" },
							lifetimeElisionHints = { enable = "skip_trivial" },
						},
					},
				},
			},
			dap = dap_cfg,
		}
	end,
	config = function()
		-- Bound per-buffer so they don't clash with anything outside Rust files.
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "rust",
			group = vim.api.nvim_create_augroup("rust-keymaps", { clear = true }),
			callback = function(event)
				local map = function(keys, cmd, desc)
					vim.keymap.set("n", keys, cmd, { buffer = event.buf, desc = "Rust: " .. desc })
				end
				map("<leader>ra", "<cmd>RustLsp codeAction<CR>", "Code [A]ction (grouped)")
				map("<leader>re", "<cmd>RustLsp explainError<CR>", "[E]xplain error")
				map("<leader>rd", "<cmd>RustLsp renderDiagnostic<CR>", "Render [D]iagnostic")
				map("<leader>rr", "<cmd>RustLsp runnables<CR>", "[R]unnables")
				map("<leader>rt", "<cmd>RustLsp testables<CR>", "[T]estables")
				map("<leader>rD", "<cmd>RustLsp debuggables<CR>", "[D]ebuggables")
				map("<leader>rm", "<cmd>RustLsp expandMacro<CR>", "Expand [M]acro")
				map("<leader>rp", "<cmd>RustLsp parentModule<CR>", "[P]arent module")
				map("<leader>rc", "<cmd>RustLsp openCargo<CR>", "Open [C]argo.toml")
				map("K", "<cmd>RustLsp hover actions<CR>", "Hover actions")
				-- Force a fresh cargo check without saving
				map("<leader>rk", "<cmd>RustLsp flyCheck run<CR>", "Run cargo chec[k] now")
			end,
		})
	end,
}

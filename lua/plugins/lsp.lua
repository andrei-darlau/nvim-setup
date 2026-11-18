-- Language server configuration.
--
-- Servers are declared in the `servers` table below and enabled with the 0.11+
-- vim.lsp.config()/vim.lsp.enable() API. nvim-lspconfig is still here because it
-- ships the default cmd/filetypes/root markers for each server.
--
-- Rust is NOT configured here -- see plugins/rustaceanvim.lua.
return {
	"neovim/nvim-lspconfig",
	dependencies = {
		{ "mason-org/mason.nvim", opts = {} },
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		{ "j-hui/fidget.nvim", opts = {} }, -- LSP progress in the corner
		"saghen/blink.cmp",
	},
	config = function()
		-- [[ Keymaps and buffer-local features on attach ]]
		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
			callback = function(event)
				local map = function(keys, func, desc, mode)
					vim.keymap.set(mode or "n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
				end

				-- In 0.11+ `grn`, `gra`, `grr`, `gri`, `grt` and `gO` are built-in
				-- default mappings. These rebindings only add which-key
				-- descriptions; deleting them loses nothing. The picker-backed ones
				-- are in plugins/telescope.lua.
				map("grn", vim.lsp.buf.rename, "[R]e[n]ame")
				map("gra", vim.lsp.buf.code_action, "[G]oto Code [A]ction", { "n", "x" })
				map("grD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

				local client = vim.lsp.get_client_by_id(event.data.client_id)

				-- Highlight other references to the symbol under the cursor
				if client and client:supports_method("textDocument/documentHighlight", event.buf) then
					local highlight_augroup = vim.api.nvim_create_augroup("lsp-highlight", { clear = false })

					vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
						buffer = event.buf,
						group = highlight_augroup,
						callback = vim.lsp.buf.document_highlight,
					})

					vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
						buffer = event.buf,
						group = highlight_augroup,
						callback = vim.lsp.buf.clear_references,
					})

					vim.api.nvim_create_autocmd("LspDetach", {
						group = vim.api.nvim_create_augroup("lsp-detach", { clear = true }),
						callback = function(event2)
							vim.lsp.buf.clear_references()
							vim.api.nvim_clear_autocmds({ group = "lsp-highlight", buffer = event2.buf })
						end,
					})
				end

				if client and client:supports_method("textDocument/inlayHint", event.buf) then
					map("<leader>th", function()
						vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
					end, "[T]oggle Inlay [H]ints")
				end
			end,
		})

		-- Give every server blink.cmp's completion capabilities via the wildcard
		-- config, instead of merging them into each server table by hand.
		vim.lsp.config("*", { capabilities = require("blink.cmp").get_lsp_capabilities() })

		-- [[ Servers ]]
		-- Keys are *lspconfig* names (underscores), not Mason package names.
		local servers = {
			clangd = {
				cmd = {
					"clangd",
					"--fallback-style=file",
					"--header-insertion=never",
					"--completion-style=detailed",
					"--clang-tidy",
				},
			},

			pyright = {},
			ruff = {},

			verible = {
				cmd = { "verible-verilog-ls", "--rules_config_search" },
				filetypes = { "verilog", "systemverilog" },
			},

			-- VHDL-LS from rust_hdl. Unlike verible it does real semantic
			-- elaboration: undeclared identifiers, port-map mismatches, type errors,
			-- goto-definition and rename across files.
			--
			-- It wants a vhdl_ls.toml in the project root to know your libraries:
			--
			--   [libraries]
			--   work.files   = ["src/**/*.vhd", "rtl/**/*.vhd"]
			--   tb.files     = ["tb/**/*.vhd"]
			--   unisim.files = ["/opt/Xilinx/.../unisims/**/*.vhd"]
			--
			-- A global one can go at ~/.config/vhdl_ls/vhdl_ls.toml. Without any
			-- config it lumps every file into `work`, which is fine for small
			-- projects and noisy for anything with real libraries.
			--
			-- Installed from the AUR here, so it's in `mason_ignore` below. The
			-- default cmd is { "vhdl_ls" }, resolved from $PATH.
			vhdl_ls = {
				settings = {
					vhdl = {
						-- "unused"/"unnecessary" show up as diagnostic hints rather
						-- than warnings; they're cheap, keep them.
						silent = false,
					},
				},
			},

			ada_ls = {},

			-- lua_ls is configured separately below, since it needs on_init.
		}

		for name, config in pairs(servers) do
			vim.lsp.config(name, config)
			vim.lsp.enable(name)
		end

		-- lua_ls, set up the way the Neovim docs recommend
		vim.lsp.config("lua_ls", {
			on_init = function(client)
				if client.workspace_folders then
					local path = client.workspace_folders[1].name
					if
						path ~= vim.fn.stdpath("config")
						and (vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc"))
					then
						return
					end
				end

				client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
					runtime = {
						version = "LuaJIT",
						path = { "lua/?.lua", "lua/?/init.lua" },
					},
					workspace = {
						checkThirdParty = false,
						library = vim.api.nvim_get_runtime_file("", true),
					},
				})
			end,
			settings = { Lua = {} },
		})
		vim.lsp.enable("lua_ls")

		vim.lsp.config("clangd", {
			cmd = {
				"clangd",
				"--background-index",
				"--clang-tidy",
				"--header-insertion=never",
				"--completion-style=detailed",
				"--fallback-style=file",
			},
			-- root = the directory nvim was started from
			root_dir = function(bufnr, on_dir)
				on_dir(vim.fn.getcwd())
			end,
		})
		vim.lsp.enable("clangd")

		-- [[ Tool installation ]]
		-- lspconfig name -> Mason package name, where they differ
		local mason_package_map = {
			ada_ls = "ada-language-server",
		}

		-- Servers installed outside Mason. Listing one here stops
		-- mason-tool-installer from trying to fetch it.
		local mason_ignore = {
			vhdl_ls = true, -- AUR package
		}

		local ensure_installed = {}
		for name, _ in pairs(servers) do
			if not mason_ignore[name] then
				table.insert(ensure_installed, mason_package_map[name] or name)
			end
		end

		vim.list_extend(ensure_installed, {
			"lua-language-server",
			"stylua",
			"clang-format", -- conform uses it for c/cpp
			"codelldb", -- used by nvim-dap and rustaceanvim
		})

		-- Not Mason packages, install them from your distro or rustup/pipx:
		--   rust-analyzer: rustup component add rust-analyzer
		--   ghdl:          pacman -S ghdl  |  apt install ghdl
		--   vsg:           pipx install vsg
		--   vhdl_ls:       AUR, or cargo install vhdl_ls

		-- Drop anything the local Mason registry doesn't have, so a renamed or
		-- absent package produces one warning instead of an error on every start.
		local ok_registry, registry = pcall(require, "mason-registry")
		if ok_registry then
			local available, missing = {}, {}
			for _, pkg in ipairs(ensure_installed) do
				local ok_has, has = pcall(registry.has_package, pkg)
				if ok_has and has then
					table.insert(available, pkg)
				else
					table.insert(missing, pkg)
				end
			end
			if #missing > 0 then
				vim.notify(
					"Mason has no package named: "
						.. table.concat(missing, ", ")
						.. " -- install these manually or fix mason_package_map.",
					vim.log.levels.WARN
				)
			end
			ensure_installed = available
		end

		require("mason-tool-installer").setup({ ensure_installed = ensure_installed })
	end,
}

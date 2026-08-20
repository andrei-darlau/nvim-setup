--[[

Kickstart-derived config, updated for Neovim 0.12.x

Changes from the previous version are marked with `-- CHANGED:` / `-- REMOVED:`
so you can audit them. See the accompanying notes for the reasoning.

VHDL support added in this revision is marked `-- ADDED (VHDL):`.

--]]

-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

-- [[ Setting options ]]
-- See `:help vim.o`

-- Allow arrow keys to wrap across lines.
-- (vim.opt is still the right tool for list/flag-style options like this one.)
vim.opt.whichwrap:append("<,>,[,]")

-- CHANGED: vim.opt -> vim.o for plain scalar options. `vim.opt` isn't deprecated,
-- but `vim.o` is the documented default in 0.11+ and is faster.
vim.o.foldmethod = "expr"
vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.o.foldlevel = 99
vim.o.number = true
-- vim.o.relativenumber = true

-- Enable mouse mode, can be useful for resizing splits for example!
vim.o.mouse = "a"

-- Don't show the mode, since it's already in the status line
vim.o.showmode = false

-- CHANGED (new in 0.11): global border for all floating windows, including
-- LSP hover/signature help. Lets you drop per-plugin `border = "rounded"` opts.
vim.o.winborder = "rounded"

-- Sync clipboard between OS and Neovim.
vim.schedule(function()
	vim.o.clipboard = "unnamedplus"
end)

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.o.signcolumn = "yes"

-- Decrease update time
vim.o.updatetime = 250

-- Decrease mapped sequence wait time
vim.o.timeoutlen = 300

-- Configure how new splits should be opened
vim.o.splitright = true
vim.o.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'` and `:help 'listchars'`
vim.o.list = false
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- CHANGED: vim.opt["tabstop"] -> vim.o.tabstop (same thing, canonical spelling)
vim.o.tabstop = 4
vim.o.shiftwidth = 4

-- Preview substitutions live, as you type!
vim.o.inccommand = "split"

-- Show which line your cursor is on
vim.o.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.o.scrolloff = 10

-- Raise a dialog on :q with unsaved changes instead of failing
vim.o.confirm = true

-- treat .asm as .nasm
vim.filetype.add({
	extension = {
		asm = "nasm",
		-- ADDED (VHDL): Neovim already maps .vhd/.vhdl/.vho/.vst/.vbe -> vhdl,
		-- so nothing is needed for those. .vht (Quartus VHDL testbench) and
		-- .vhs are not in the default table.
		vht = "vhdl",
		vhs = "vhdl",
	},
})

-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Clear highlights on search when pressing <Esc> in normal mode
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Keep visual mode active after indenting
vim.keymap.set("v", "<", "<gv", { desc = "Indent left and keep selection" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right and keep selection" })

-- Diagnostic Config & Keymaps
-- See :help vim.diagnostic.Opts
vim.diagnostic.config({
	-- Note: this only controls *rendering*. It does not make a language server
	-- re-analyse anything. See the rust-analyzer settings below for that.
	update_in_insert = true,
	severity_sort = true,
	float = { source = "if_many" }, -- border now comes from 'winborder'
	underline = { severity = vim.diagnostic.severity.ERROR },

	virtual_text = true, -- Text shows up at the end of the line
	virtual_lines = false, -- Text shows up underneath the line, with virtual lines

	-- Auto open the float when jumping with `[d` / `]d`
	-- CHANGED: guard against nil, on_jump is called with (diagnostic, bufnr)
	-- and diagnostic is nil when the jump found nothing.
	jump = {
		on_jump = function(diagnostic, bufnr)
			if not diagnostic then
				return
			end
			vim.diagnostic.open_float({ bufnr = bufnr, scope = "cursor", focus = false })
		end,
	},
})

vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

-- Toggle between inline virtual text and full virtual lines. Handy in Rust,
-- where borrow-checker errors are far too long for end-of-line text.
vim.keymap.set("n", "<leader>td", function()
	local cfg = vim.diagnostic.config()
	local to_lines = not cfg.virtual_lines
	vim.diagnostic.config({
		virtual_lines = to_lines and { current_line = true } or false,
		virtual_text = not to_lines,
	})
end, { desc = "[T]oggle [D]iagnostic virtual lines" })

-- Exit terminal mode in the builtin terminal with an easier shortcut
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Keybinds to make split navigation easier.
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

-- Move lines up and down
vim.keymap.set("n", "<A-Up>", "<cmd>m .-2<cr>==", { desc = "Move line up" })
vim.keymap.set("n", "<A-Down>", "<cmd>m .+1<cr>==", { desc = "Move line down" })
vim.keymap.set("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Move line up (hjkl)" })
vim.keymap.set("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Move line down (hjkl)" })

-- Visual-mode commands (moves highlighted blocks)
vim.keymap.set("v", "<A-Up>", ":m '<-2<cr>gv=gv", { desc = "Move block up" })
vim.keymap.set("v", "<A-Down>", ":m '>+1<cr>gv=gv", { desc = "Move block down" })
vim.keymap.set("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Move block up (hjkl)" })
vim.keymap.set("v", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "Move block down (hjkl)" })

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})

-- [[ Install `lazy.nvim` plugin manager ]]
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
-- CHANGED: `vim.loop` is deprecated; 0.12 always has `vim.uv`, so the fallback is dead code.
if not vim.uv.fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		error("Error cloning lazy.nvim:\n" .. out)
	end
end

---@type vim.Option
local rtp = vim.opt.rtp
rtp:prepend(lazypath)

-- [[ Configure and install plugins ]]
require("lazy").setup({
	{ "NMAC427/guess-indent.nvim", opts = {} },

	{ -- Adds git related signs to the gutter, as well as utilities for managing changes
		"lewis6991/gitsigns.nvim",
		opts = {
			signs = {
				add = { text = "+" },
				change = { text = "~" },
				delete = { text = "_" },
				topdelete = { text = "‾" },
				changedelete = { text = "~" },
			},
		},
	},

	{
		"okuuva/auto-save.nvim",
		opts = {
			enabled = true,
			-- CHANGED: 135ms -> 1000ms.
			-- Every write makes rust-analyzer kick off a `cargo check`. At 135ms you
			-- were queuing a fresh check every time you paused typing, so checks kept
			-- cancelling/queuing each other and diagnostics appeared to never land.
			debounce_delay = 1000,
			condition = function(buf)
				return vim.bo[buf].filetype ~= "" and vim.bo[buf].modifiable
			end,
		},
	},

	-------------------------------------------------------------------------
	-- Rust
	--
	-- rustaceanvim owns the rust-analyzer client entirely. Do NOT also
	-- configure/enable rust_analyzer through nvim-lspconfig or vim.lsp.enable --
	-- you get two clients fighting over the same buffer.
	-------------------------------------------------------------------------
	{
		"mrcjkb/rustaceanvim",
		-- CHANGED: ^5 -> ^6. If lazy errors that no matching version exists,
		-- delete this line to track latest.
		version = "^6",
		-- CHANGED: was `ft = "rust"`. rustaceanvim is *already* lazy internally and
		-- its README explicitly says not to lazy-load it. With `ft`, the plugin's
		-- own runtime file read `vim.g.rustaceanvim` BEFORE your `config` function
		-- ran -- so every setting you wrote here was silently discarded.
		lazy = false,
		-- CHANGED: config -> init, so the global exists before the plugin reads it.
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
				tools = {
					float_win_config = { border = "rounded" },
				},
				server = {
					default_settings = {
						["rust-analyzer"] = {
							-- === THE LIVE-UPDATE FIX ===
							-- rust-analyzer has two diagnostic sources:
							--   1. native analysis  -> updates on every keystroke
							--   2. `cargo check`    -> only runs on save
							-- Enabling the experimental native diagnostics gets you
							-- type/name errors as you type, without waiting on cargo.
							diagnostics = {
								enable = true,
								experimental = { enable = true },
								styleLints = { enable = true },
							},

							-- CHANGED: your old `checkOnSave = { command = "clippy" }`
							-- is the pre-2024 schema. rust-analyzer now expects
							-- `checkOnSave` to be a BOOLEAN and the command to live
							-- under `check.command`. The old form is ignored, which is
							-- why clippy never ran.
							checkOnSave = true,
							check = {
								command = "clippy",
								extraArgs = { "--no-deps" },
								allTargets = false,
							},

							cargo = {
								allFeatures = true,
								buildScripts = { enable = true },
								-- === THE OTHER HALF OF THE FIX ===
								-- Give rust-analyzer its own target dir. Otherwise its
								-- `cargo check` and any `cargo build/run/check` you type
								-- in a terminal block on the same target/ lock. That is
								-- exactly the "I have to run cargo check by hand and
								-- restart nvim" symptom: RA's check was sitting on a
								-- lock, then your manual run warmed the cache.
								targetDir = true, -- -> target/rust-analyzer
							},

							procMacro = {
								enable = true,
								ignored = {
									-- common offenders that hang proc-macro expansion
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
	},

	-- REMOVED: "rust-lang/rust.vim"
	--
	-- Three separate reasons:
	--  1. `vim.g.rustfmt_autosave = 1` formatted the buffer on every BufWritePre.
	--     Combined with auto-save.nvim's 135ms debounce, your file was being
	--     rustfmt'd every time you stopped typing -- including mid-edit, on
	--     half-written code that rustfmt refuses to parse.
	--  2. It fights conform.nvim over who owns formatting.
	--  3. rustaceanvim + treesitter already cover everything else it provided.
	--     Formatting now goes through conform (see the conform block below).

	{
		"mfussenegger/nvim-dap",
		config = function()
			local dap, dapui = require("dap"), require("dapui")

			dap.listeners.before.attach.dapui_config = function()
				dapui.open()
			end
			dap.listeners.before.launch.dapui_config = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated.dapui_config = function()
				dapui.close()
			end
			dap.listeners.before.event_exited.dapui_config = function()
				dapui.close()
			end

			local extension_path = vim.fn.stdpath("data") .. "/mason/packages/codelldb/extension/"
			local codelldb_path = extension_path .. "adapter/codelldb"

			dap.adapters.codelldb = {
				type = "server",
				port = "${port}",
				executable = {
					command = codelldb_path,
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
			-- Rust DAP configs come from rustaceanvim (`:RustLsp debuggables`).
		end,
	},

	{
		"rcarriga/nvim-dap-ui",
		dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
		config = function()
			require("dapui").setup()
		end,
	},

	{
		"saecki/crates.nvim",
		ft = { "toml" },
		config = function()
			require("crates").setup({
				lsp = {
					enabled = true,
					actions = true,
					completion = true,
					hover = true,
				},
				completion = {
					crates = { enabled = true },
				},
			})
		end,
	},

	{
		"nvim-tree/nvim-tree.lua",
		version = "*",
		lazy = false,
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
		config = function()
			require("nvim-tree").setup({
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
			})
		end,
	},

	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = true,
	},

	{
		"MeanderingProgrammer/render-markdown.nvim",
		dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
		ft = { "markdown" },
		config = function()
			require("render-markdown").setup({})

			vim.api.nvim_create_autocmd("FileType", {
				pattern = "markdown",
				callback = function(event)
					vim.keymap.set("n", "<leader>tp", "<cmd>RenderMarkdown toggle<CR>", {
						buffer = event.buf,
						desc = "[T]oggle Markdown [P]review",
					})
				end,
			})
		end,
	},

	{ -- Useful plugin to show you pending keybinds.
		"folke/which-key.nvim",
		event = "VimEnter",
		opts = {
			delay = 0,
			icons = { mappings = vim.g.have_nerd_font },

			spec = {
				{ "<leader>s", group = "[S]earch", mode = { "n", "v" } },
				{ "<leader>t", group = "[T]oggle" },
				{ "<leader>h", group = "Git [H]unk", mode = { "n", "v" } },
				{ "<leader>d", group = "[D]ebug" },
				{ "<leader>r", group = "[R]ust" },
			},
		},
	},

	{
		"mbbill/undotree",
		config = function()
			vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle, { desc = "Toggle [U]ndo Tree" })
		end,
	},

	{ -- Fuzzy Finder (files, lsp, etc)
		"nvim-telescope/telescope.nvim",
		enabled = true,
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
			{ "nvim-telescope/telescope-ui-select.nvim" },
			{ "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
		},
		config = function()
			-- [[ Configure Telescope ]]
			-- See `:help telescope` and `:help telescope.setup()`
			require("telescope").setup({
				extensions = {
					["ui-select"] = { require("telescope.themes").get_dropdown() },
				},
			})

			pcall(require("telescope").load_extension, "fzf")
			pcall(require("telescope").load_extension, "ui-select")

			-- See `:help telescope.builtin`
			local builtin = require("telescope.builtin")
			vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
			vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
			vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "[S]earch [F]iles" })
			vim.keymap.set("n", "<leader>ss", builtin.builtin, { desc = "[S]earch [S]elect Telescope" })
			vim.keymap.set({ "n", "v" }, "<leader>sw", builtin.grep_string, { desc = "[S]earch current [W]ord" })
			vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "[S]earch by [G]rep" })
			vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
			vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "[S]earch [R]esume" })
			vim.keymap.set("n", "<leader>s.", builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
			vim.keymap.set("n", "<leader>sc", builtin.commands, { desc = "[S]earch [C]ommands" })
			vim.keymap.set("n", "<leader><leader>", builtin.buffers, { desc = "[ ] Find existing buffers" })

			local map = vim.keymap.set

			map("n", ";", ":", { desc = "CMD enter command mode" })

			-- Nvim DAP
			map("n", "<Leader>dl", function()
				require("dap").step_into()
			end, { desc = "Debugger step into" })
			map("n", "<Leader>dj", function()
				require("dap").step_over()
			end, { desc = "Debugger step over" })
			map("n", "<Leader>dk", function()
				require("dap").step_out()
			end, { desc = "Debugger step out" })
			map("n", "<Leader>dc", function()
				require("dap").continue()
			end, { desc = "Debugger continue" })
			map("n", "<Leader>db", function()
				require("dap").toggle_breakpoint()
			end, { desc = "Debugger toggle breakpoint" })
			map("n", "<Leader>dd", function()
				require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
			end, { desc = "Debugger set conditional breakpoint" })
			map("n", "<Leader>de", function()
				require("dap").terminate()
			end, { desc = "Debugger reset" })
			map("n", "<Leader>dr", function()
				require("dap").run_last()
			end, { desc = "Debugger run last" })

			-- LSP pickers, bound on attach so you can swap pickers easily.
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("telescope-lsp-attach", { clear = true }),
				callback = function(event)
					local buf = event.buf

					vim.keymap.set("n", "grr", builtin.lsp_references, { buffer = buf, desc = "[G]oto [R]eferences" })
					vim.keymap.set(
						"n",
						"gri",
						builtin.lsp_implementations,
						{ buffer = buf, desc = "[G]oto [I]mplementation" }
					)
					vim.keymap.set("n", "grd", builtin.lsp_definitions, { buffer = buf, desc = "[G]oto [D]efinition" })
					vim.keymap.set(
						"n",
						"gO",
						builtin.lsp_document_symbols,
						{ buffer = buf, desc = "Open Document Symbols" }
					)
					vim.keymap.set(
						"n",
						"gW",
						builtin.lsp_dynamic_workspace_symbols,
						{ buffer = buf, desc = "Open Workspace Symbols" }
					)
					vim.keymap.set(
						"n",
						"grt",
						builtin.lsp_type_definitions,
						{ buffer = buf, desc = "[G]oto [T]ype Definition" }
					)
				end,
			})

			-- Override default behavior and theme when searching
			vim.keymap.set("n", "<leader>/", function()
				builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
					winblend = 10,
					previewer = false,
				}))
			end, { desc = "[/] Fuzzily search in current buffer" })

			vim.keymap.set("n", "<leader>s/", function()
				builtin.live_grep({
					grep_open_files = true,
					prompt_title = "Live Grep in Open Files",
				})
			end, { desc = "[S]earch [/] in Open Files" })

			vim.keymap.set("n", "<leader>sn", function()
				builtin.find_files({ cwd = vim.fn.stdpath("config") })
			end, { desc = "[S]earch [N]eovim files" })
		end,
	},

	-- LSP Plugins
	{
		-- Main LSP Configuration
		"neovim/nvim-lspconfig",
		dependencies = {
			{ "mason-org/mason.nvim", opts = {} },
			"WhoIsSethDaniel/mason-tool-installer.nvim",
			{ "j-hui/fidget.nvim", opts = {} },
			"saghen/blink.cmp",
		},
		config = function()
			--  This function gets run when an LSP attaches to a particular buffer.
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
				callback = function(event)
					local map = function(keys, func, desc, mode)
						mode = mode or "n"
						vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
					end

					-- NOTE: in 0.11+ `grn`, `gra`, `grr`, `gri`, `grt` and `gO` are
					-- built-in default mappings. These re-bindings exist only to give
					-- them which-key descriptions; deleting them loses nothing.
					map("grn", vim.lsp.buf.rename, "[R]e[n]ame")
					map("gra", vim.lsp.buf.code_action, "[G]oto Code [A]ction", { "n", "x" })
					map("grD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

					local client = vim.lsp.get_client_by_id(event.data.client_id)
					if client and client:supports_method("textDocument/documentHighlight", event.buf) then
						local highlight_augroup =
							vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
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
							group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
							callback = function(event2)
								vim.lsp.buf.clear_references()
								vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = event2.buf })
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

			-- CHANGED: apply blink's capabilities to every server via the 0.11+
			-- wildcard config instead of merging it into each server table by hand.
			local capabilities = require("blink.cmp").get_lsp_capabilities()
			vim.lsp.config("*", { capabilities = capabilities })

			-- Enable the following language servers.
			-- NOTE: keys must be *lspconfig* names (underscores), not Mason package
			-- names and not the rust-analyzer binary name.
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
				-- gopls = {},
				pyright = {},
				ruff = {},

				-- REMOVED: ["rust-analyzer"] = { checkOnSave = { command = "clippy" } }
				--
				-- This entry was dead in three different ways:
				--   * the lspconfig name is `rust_analyzer`, not `rust-analyzer`, so
				--     vim.lsp.enable() found no config with a cmd/filetypes and never
				--     attached anything;
				--   * settings must be nested under settings["rust-analyzer"], not
				--     placed at the top level of the server table;
				--   * checkOnSave-as-a-table is the old schema (see rustaceanvim above).
				-- Rust is handled entirely by rustaceanvim now.

				verible = {
					cmd = { "verible-verilog-ls", "--rules_config_search" },
					filetypes = { "verilog", "systemverilog" },
				},

				-- ADDED (VHDL): VHDL-LS from rust_hdl. This is the VHDL equivalent of
				-- verible + verilator combined -- unlike verible it does real semantic
				-- elaboration, so you get "no declaration for X", port-map mismatches,
				-- type errors, goto-definition and rename across files.
				--
				-- Defaults are fine (cmd = { "vhdl_ls" }, filetypes = { "vhdl" }), but
				-- it wants a `vhdl_ls.toml` in the project root to know your libraries:
				--
				--   [libraries]
				--   work.files  = ["src/**/*.vhd", "rtl/**/*.vhd"]
				--   tb.files    = ["tb/**/*.vhd"]
				--   unisim.files = ["/opt/Xilinx/.../unisims/**/*.vhd"]
				--
				-- You can also put a global one at ~/.config/vhdl_ls/vhdl_ls.toml.
				-- Without any config it lumps every file it finds into `work`, which
				-- is fine for small projects and noisy for anything with real libs.
				--
				-- Install: `cargo install vhdl_ls` (or Mason, see the map below).
				-- Alternative if you prefer GHDL's front end: `ghdl_ls = {}`, from the
				-- ghdl-language-server python package. Don't enable both.
				vhdl_ls = {
          cmd = { "/usr/bin/vhdl_ls" },
					settings = {
						-- VHDL-LS reads most things from vhdl_ls.toml, but the LSP
						-- settings below control the non-project-specific bits.
						vhdl = {
							-- "unused"/"unnecessary" hints show up as diagnostic hints
							-- rather than warnings; keep them, they're cheap.
							silent = false,
						},
					},
				},

				ada_ls = {},
			}

			-- Map lspconfig names to Mason package names when they differ
			local mason_package_map = {
				ada_ls = "ada-language-server",
				-- ADDED (VHDL): mason has shipped VHDL-LS under both `vhdl_ls` and
				-- `rust_hdl` depending on registry version. The has_package filter
				-- below means a wrong guess degrades to a one-line warning instead
				-- of an error toast on every startup.
				vhdl_ls = "vhdl_ls",
			}

      local mason_ignore = {
        vhdl_ls = true, -- AUR package
      }

			local ensure_installed = {}
			for server_name, _ in pairs(servers) do
				table.insert(ensure_installed, mason_package_map[server_name] or server_name)
			end

			vim.list_extend(ensure_installed, {
				"lua-language-server",
				"stylua",
				"clang-format", -- conform uses it for c/cpp
				"codelldb", -- used by nvim-dap and rustaceanvim
			})

			-- NOTE: rust-analyzer is deliberately NOT in this list. Install it with
			--   rustup component add rust-analyzer
			-- so it always matches your toolchain. Mason's build regularly drifts out
			-- of sync with rustup and produces "failed to find sysroot" errors.
			--
			-- Same reasoning applies to the VHDL toolchain: `ghdl` and `vsg` are not
			-- Mason packages. Install them from your distro / pipx:
			--   ghdl: pacman -S ghdl | apt install ghdl | nix profile install nixpkgs#ghdl
			--   vsg:  pipx install vsg

			-- ADDED (VHDL): drop anything the local Mason registry doesn't actually
			-- have, so a renamed/absent package can't break startup.
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

			for name, server in pairs(servers) do
				vim.lsp.config(name, server)
				vim.lsp.enable(name)
			end

			-- Special Lua Config, as recommended by neovim help docs
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
				settings = {
					Lua = {},
				},
			})
			vim.lsp.enable("lua_ls")
		end,
	},

	{ -- Semantic linting for Verilog/SystemVerilog, syntax linting for VHDL
		"mfussenegger/nvim-lint",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			local lint = require("lint")
			lint.linters_by_ft = {
				verilog = { "verilator" },
				systemverilog = { "verilator" },
			}
			lint.linters.verilator.args = {
				"--lint-only",
				"-Wall",
				"--bbox-sys",
			}

			-- ADDED (VHDL): nvim-lint ships no ghdl linter, so define one.
			--
			-- `-s` is *syntax only*: it parses the file and exits without touching
			-- the work library, so it never writes .cf/.o files into your tree and
			-- never needs dependencies analysed first. Semantic errors (undeclared
			-- signals, width mismatches, bad port maps) come from vhdl_ls, which
			-- already elaborates the whole design -- running `ghdl -a` here as well
			-- would just duplicate that, more slowly and with a dirty work dir.
			--
			-- Bump --std if you're on '93: ghdl accepts 87/93/93c/00/02/08/19.
			lint.linters.ghdl = {
				cmd = "ghdl",
				stdin = false,
				append_fname = true,
				args = {
					"-s",
					"--std=08",
					"-frelaxed-rules",
					"--warn-no-hide",
				},
				stream = "stderr",
				ignore_exitcode = true,
				parser = function(output, _bufnr)
					local diagnostics = {}
					for line in vim.gsplit(output or "", "\n", { trimempty = true }) do
						-- ghdl:  path/to/file.vhd:12:5: message
						--        path/to/file.vhd:12:5:warning: message
						local lnum, col, rest = line:match("^[^:]*:(%d+):(%d+):%s*(.*)$")
						if lnum then
							local severity = vim.diagnostic.severity.ERROR
							local message = rest
							local kind, tail = rest:match("^(%a+):%s*(.*)$")
							if kind == "warning" then
								severity, message = vim.diagnostic.severity.WARN, tail
							elseif kind == "note" then
								severity, message = vim.diagnostic.severity.INFO, tail
							elseif kind == "error" then
								message = tail
							end
							table.insert(diagnostics, {
								lnum = tonumber(lnum) - 1,
								col = tonumber(col) - 1,
								end_lnum = tonumber(lnum) - 1,
								end_col = tonumber(col),
								severity = severity,
								source = "ghdl",
								message = message,
							})
						end
					end
					return diagnostics
				end,
			}

			-- Only wire ghdl up if it's actually on PATH, otherwise every save in a
			-- .vhd buffer produces a "command not found" notification.
			if vim.fn.executable("ghdl") == 1 then
				lint.linters_by_ft.vhdl = { "ghdl" }
			end

			local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
			vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
				group = lint_augroup,
				callback = function()
					-- CHANGED: only run linters that are actually configured for this
					-- filetype. Previously this fired try_lint() on every buffer,
					-- including Rust ones, on every InsertLeave.
					if lint.linters_by_ft[vim.bo.filetype] then
						lint.try_lint()
					end
				end,
			})

			-- Debounced "as you type" linting for the HDL filetypes.
			-- CHANGED (VHDL): generalised from Verilog-only. Both verilator and ghdl
			-- read from disk rather than stdin, hence the forced write.
			local hdl_lint_fts = {
				verilog = true,
				systemverilog = true,
				vhdl = true,
			}
			local hdl_lint_timer = nil
			vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
				group = lint_augroup,
				pattern = { "*.v", "*.sv", "*.svh", "*.vhd", "*.vhdl", "*.vho", "*.vht", "*.vhs" },
				callback = function(args)
					local ft = vim.bo[args.buf].filetype
					if not hdl_lint_fts[ft] or not lint.linters_by_ft[ft] then
						return
					end
					if hdl_lint_timer then
						pcall(function()
							hdl_lint_timer:stop()
						end)
					end
					hdl_lint_timer = vim.defer_fn(function()
						if vim.api.nvim_buf_is_valid(args.buf) and vim.bo[args.buf].modified then
							vim.api.nvim_buf_call(args.buf, function()
								vim.cmd("silent! write")
							end)
						end
						require("lint").try_lint()
					end, 500)
				end,
			})
		end,
	},

	{ -- Autoformat
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		keys = {
			{
				"<leader>f",
				function()
					require("conform").format({ async = true, lsp_format = "fallback" })
				end,
				mode = "",
				desc = "[F]ormat buffer",
			},
		},
		opts = {
			notify_on_error = false,
			-- Left off deliberately: auto-save.nvim writes for you, and
			-- format-on-save + autosave means your buffer gets rewritten while you
			-- are still typing. Use <leader>f.
			format_on_save = false,

			-- ADDED (VHDL): conform has no built-in vsg definition, so declare one.
			-- vsg (VHDL Style Guide) rewrites the file in place rather than writing
			-- to stdout, so stdin = false and let conform hand it a temp file via
			-- $FILENAME and read the result back.
			--
			--   pipx install vsg
			--
			-- Rules are configured per project with a vsg_config.yaml; add
			--   args = { "--fix", "-c", "vsg_config.yaml", "-f", "$FILENAME" }
			-- if you keep one at the project root.
			formatters = {
				vsg = {
					command = "vsg",
					stdin = false,
					args = { "--fix", "-f", "$FILENAME" },
					-- vsg exits 1 when it found rule violations, including ones it
					-- just fixed. Without this conform treats every fix as a failure.
					exit_codes = { 0, 1 },
				},
			},

			formatters_by_ft = {
				lua = { "stylua" },
				c = { "clang-format" },
				cpp = { "clang-format" },
				verilog = { "verible-verilog-format" },
				systemverilog = { "verible-verilog-format" },
				-- ADDED (VHDL): vsg if installed, otherwise fall back to whatever
				-- the attached LSP offers (recent VHDL-LS versions do implement
				-- textDocument/formatting; older ones simply do nothing).
				vhdl = { "vsg", lsp_format = "fallback" },
				-- CHANGED: rust formatting now lives here instead of rust.vim's
				-- rustfmt_autosave. Going through the LSP means rustfmt picks up the
				-- edition and rustfmt.toml from your Cargo project, which a bare
				-- `rustfmt` invocation does not.
				rust = { lsp_format = "prefer" },
			},
		},
	},

	{ -- Autocompletion
		"saghen/blink.cmp",
		event = "VimEnter",
		version = "1.*",
		dependencies = {
			{
				"L3MON4D3/LuaSnip",
				version = "2.*",
				build = (function()
					if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
						return
					end
					return "make install_jsregexp"
				end)(),
				dependencies = {},
				opts = {},
			},
		},
		--- @module 'blink.cmp'
		--- @type blink.cmp.Config
		opts = {
			keymap = {
				preset = "default",
			},

			appearance = {
				nerd_font_variant = "mono",
			},

			completion = {
				documentation = { auto_show = false, auto_show_delay_ms = 500 },
			},

			sources = {
				default = { "lsp", "path", "snippets" },
			},

			snippets = { preset = "luasnip" },

			fuzzy = { implementation = "lua" },

			signature = { enabled = true },
		},
	},

	{ -- Colorscheme
		"folke/tokyonight.nvim",
		priority = 1000,
		config = function()
			---@diagnostic disable-next-line: missing-fields
			require("tokyonight").setup({
				styles = {
					comments = { italic = false },
				},
				-- NOTE (VHDL): these are global capture->color links, not per-language.
				-- VHDL picks them up automatically as soon as the vhdl query file in
				-- after/queries/vhdl/highlights.scm assigns the same capture names.
				-- Nothing language-specific needs to be added here.
				on_highlights = function(hl, c)
					hl["@variable.parameter"] = { fg = c.orange }
					hl["@property"] = { fg = c.cyan }
					hl["@keyword.repeat"] = { fg = c.magenta } -- always/initial, process
					hl["@punctuation.bracket"] = { fg = c.teal } -- begin/end + ()[]{}
					hl["@keyword.edge"] = { fg = c.yellow } -- posedge/negedge, rising_edge/falling_edge
				end,
			})

			vim.cmd.colorscheme("tokyonight-night")
		end,
	},

	-- Highlight todo, notes, etc in comments
	{
		"folke/todo-comments.nvim",
		event = "VimEnter",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = { signs = false },
	},

	{ -- Collection of various small independent plugins/modules
		"nvim-mini/mini.nvim",
		config = function()
			require("mini.ai").setup({ n_lines = 500 })
			require("mini.surround").setup()

			local statusline = require("mini.statusline")
			statusline.setup({ use_icons = vim.g.have_nerd_font })

			---@diagnostic disable-next-line: duplicate-set-field
			statusline.section_location = function()
				return "%2l:%-2v"
			end
		end,
	},

	-------------------------------------------------------------------------
	-- Treesitter
	--
	-- CHANGED: migrated from the `master` branch to `main`.
	-- The master branch is frozen/deprecated upstream and the whole
	-- `nvim-treesitter.configs` API (ensure_installed / highlight / indent
	-- tables) is gone on `main`. Setup is now: install parsers, then start
	-- treesitter per-buffer yourself.
	--
	-- If this misbehaves, the old master-branch block is preserved in a comment
	-- directly below and you can swap back with no other changes.
	-------------------------------------------------------------------------
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false,
		build = ":TSUpdate",
		config = function()
			local ts = require("nvim-treesitter")
			ts.setup({})

			local parsers = {
				"bash",
				"c",
				"cpp",
				"diff",
				"html",
				"lua",
				"luadoc",
				"markdown",
				"markdown_inline",
				"query",
				"vim",
				"vimdoc",
				"asm",
				"systemverilog",
				-- ADDED (VHDL): note there is no separate "systemverilog" parser --
				-- the `verilog` parser covers both -- but VHDL is its own grammar.
				"vhdl",
				"ada",
				-- ADDED: you write Rust but had no rust/toml parsers listed.
				"rust",
				"toml",
				"python",
				"json",
				"yaml",
			}

			-- install() is async and skips anything already present.
			pcall(function()
				ts.install(parsers)
			end)

			vim.treesitter.language.register("systemverilog", { "verilog", "systemverilog" })
			
      vim.api.nvim_create_autocmd("FileType", {
				group = vim.api.nvim_create_augroup("treesitter-start", { clear = true }),
				callback = function(args)
					local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
					if not lang then
						return
					end
					-- Fails harmlessly if the parser isn't installed yet.
					if not pcall(vim.treesitter.start, args.buf, lang) then
						return
					end
					-- Treesitter indentation is opt-in per buffer on the main branch.
					vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end,
			})
		end,
	},

	-- Previous (master-branch) treesitter block, kept for easy rollback:
	--
	-- {
	-- 	"nvim-treesitter/nvim-treesitter",
	-- 	branch = "master",
	-- 	build = ":TSUpdate",
	-- 	main = "nvim-treesitter.configs",
	-- 	opts = {
	-- 		ensure_installed = { "bash", "c", "cpp", "diff", "html", "lua", "luadoc",
	-- 			"markdown", "markdown_inline", "query", "vim", "vimdoc", "asm",
	-- 			"verilog", "vhdl", "ada", "rust", "toml" },
	-- 		auto_install = true,
	-- 		highlight = { enable = true },
	-- 		indent = { enable = true },
	-- 	},
	-- },

	-- NOTE: Next step on your Neovim journey: Add/Configure additional plugins
	-- require 'kickstart.plugins.debug',
	-- require 'kickstart.plugins.indent_line',
	-- require 'kickstart.plugins.lint',
	-- require 'kickstart.plugins.autopairs',
	-- require 'kickstart.plugins.neo-tree',
	-- require 'kickstart.plugins.gitsigns',
	-- { import = 'custom.plugins' },
}, {
	ui = {
		icons = vim.g.have_nerd_font and {} or {
			cmd = "⌘",
			config = "🛠",
			event = "📅",
			ft = "📂",
			init = "⚙",
			keys = "🗝",
			plugin = "🔌",
			runtime = "💻",
			require = "🌙",
			source = "📄",
			start = "🚀",
			task = "📌",
			lazy = "💤 ",
		},
	},
})

-- [[ Rust keymaps (rustaceanvim) ]]
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

-- ADDED (VHDL): comment string. Neovim's built-in vhdl ftplugin sets
-- commentstring correctly ("-- %s") on recent versions; this is a no-op guard
-- for older ones and for buffers that only got a filetype from the table above.
vim.api.nvim_create_autocmd("FileType", {
	pattern = "vhdl",
	group = vim.api.nvim_create_augroup("vhdl-buffer-opts", { clear = true }),
	callback = function(event)
		if vim.bo[event.buf].commentstring == "" then
			vim.bo[event.buf].commentstring = "-- %s"
		end
		-- VHDL convention is 2-space indent; drop these two lines if you'd
		-- rather keep the global 4.
		vim.bo[event.buf].shiftwidth = 2
		vim.bo[event.buf].tabstop = 2
		vim.bo[event.buf].expandtab = true
	end,
})

-- ADDED (VHDL): quick helper for the treesitter query file. Run
-- `:VhdlTsSymbols process` (or begin/end/...) in a VHDL buffer to see exactly
-- what the installed vhdl grammar calls its keyword nodes. Use the output to
-- correct after/queries/vhdl/highlights.scm if the names there don't match.
vim.api.nvim_create_user_command("VhdlTsSymbols", function(opts)
	local ok, info = pcall(vim.treesitter.language.inspect, "vhdl")
	if not ok then
		vim.notify("vhdl parser not installed", vim.log.levels.ERROR)
		return
	end
	local needle = (opts.args ~= "" and opts.args or ""):lower()
	local names = {}
	for _, sym in ipairs(info.symbols or {}) do
		local name = type(sym) == "table" and sym[1] or sym
		if type(name) == "string" and (needle == "" or name:lower():find(needle, 1, true)) then
			table.insert(names, name)
		end
	end
	table.sort(names)
	vim.print(names)
end, { nargs = "?", desc = "List vhdl treesitter node names matching a substring" })

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et

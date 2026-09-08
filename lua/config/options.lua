-- [[ Options ]]
-- See `:help vim.o` and `:help option-list`

-- Line numbers
vim.o.number = true
-- vim.o.relativenumber = true

-- Folding via treesitter, all folds open on entry
vim.o.foldmethod = "expr"
vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.o.foldlevel = 99

-- Enable mouse mode, useful for resizing splits
vim.o.mouse = "a"

-- Don't show the mode, it's already in the status line
vim.o.showmode = false

-- Global border for every floating window, including LSP hover and signature
-- help. Removes the need for per-plugin `border = "rounded"` options.
vim.o.winborder = "rounded"

-- Sync clipboard between OS and Neovim. Scheduled so it doesn't slow startup.
vim.schedule(function()
	vim.o.clipboard = "unnamedplus"
end)

-- Wrapped lines keep the indentation of the line they continue
vim.o.breakindent = true

-- Save undo history to disk
vim.o.undofile = true

-- Case-insensitive search unless the pattern has \C or a capital letter
vim.o.ignorecase = true
vim.o.smartcase = true

-- Always draw the sign column so text doesn't jump around
vim.o.signcolumn = "yes"

-- Faster CursorHold (document highlight, diagnostics on hover)
vim.o.updatetime = 250

-- Time to wait for a mapped sequence to complete
vim.o.timeoutlen = 300

-- New splits open right and below
vim.o.splitright = true
vim.o.splitbelow = true

-- Indentation. guess-indent.nvim overrides these per buffer when it can.
vim.o.tabstop = 4
vim.o.shiftwidth = 4

-- Whitespace rendering, off by default. See `:help 'listchars'`
vim.o.list = false
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- Live preview of :substitute in a split
vim.o.inccommand = "split"

-- Highlight the cursor line
vim.o.cursorline = true

-- Keep this many lines visible above/below the cursor
vim.o.scrolloff = 10

-- Ask on :q with unsaved changes instead of erroring
vim.o.confirm = true

-- Arrow keys wrap across lines. `vim.opt` is the right tool for list-style
-- options like this one; plain scalars use `vim.o`.
vim.opt.whichwrap:append("<,>,[,]")

-- [[ Filetypes ]]
-- Neovim already maps .vhd/.vhdl/.vho/.vst/.vbe to vhdl. .vht (Quartus VHDL
-- testbench) and .vhs are not in the default table.
vim.filetype.add({
	extension = {
		asm = "nasm",
		vht = "vhdl",
		vhs = "vhdl",
	},
})

-- [[ Diagnostics ]]
-- See `:help vim.diagnostic.Opts`
vim.diagnostic.config({
	-- This controls rendering only. It does not make a language server
	-- re-analyse anything -- see the rust-analyzer settings in
	-- lua/plugins/rustaceanvim.lua for that.
	update_in_insert = true,
	severity_sort = true,
	float = { source = "if_many" }, -- border comes from 'winborder'
	underline = { severity = vim.diagnostic.severity.ERROR },

	virtual_text = true, -- at the end of the line
	virtual_lines = false, -- underneath the line, toggled by <leader>td

	-- Open the float automatically when jumping with [d / ]d.
	-- `diagnostic` is nil when the jump found nothing.
	jump = {
		on_jump = function(diagnostic, bufnr)
			if not diagnostic then
				return
			end
			vim.diagnostic.open_float({ bufnr = bufnr, scope = "cursor", focus = false })
		end,
	},
})

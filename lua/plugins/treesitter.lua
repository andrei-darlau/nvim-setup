-- Treesitter: parsing, highlighting, indentation and folds.
--
-- This uses the `main` branch. The `master` branch is frozen upstream and its
-- `nvim-treesitter.configs` API (ensure_installed / highlight / indent tables)
-- does not exist here. Setup is: install parsers, then start treesitter
-- per-buffer yourself.
return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	lazy = false,
	build = ":TSUpdate",
	config = function()
		local ts = require("nvim-treesitter")
		ts.setup({})

		local parsers = {
			"asm",
			"ada",
			"bash",
			"c",
			"cpp",
			"diff",
			"html",
			"json",
			"lua",
			"luadoc",
			"markdown",
			"markdown_inline",
			"mips",
			"python",
			"query",
			"rust",
			"systemverilog",
			"toml",
			"vhdl",
			"vim",
			"vimdoc",
			"yaml",
		}

		-- install() is async and skips anything already present.
		pcall(function()
			ts.install(parsers)
		end)

		-- Map filetypes onto parsers whose names don't match. The systemverilog
		-- grammar handles plain Verilog too, and the asm grammar handles nasm.
		vim.treesitter.language.register("systemverilog", { "verilog", "systemverilog" })
		vim.treesitter.language.register("asm", { "nasm" })

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

		-- Helper for writing query files. Run `:TSSymbols vhdl process` to see
		-- what the installed grammar actually calls its nodes, then fix the
		-- capture names in after/queries/<lang>/highlights.scm to match.
		vim.api.nvim_create_user_command("TSSymbols", function(opts)
			local lang = opts.fargs[1]
			local needle = (opts.fargs[2] or ""):lower()

			local ok, info = pcall(vim.treesitter.language.inspect, lang)
			if not ok then
				vim.notify(("%s parser not installed"):format(lang), vim.log.levels.ERROR)
				return
			end

			local names = {}
			for _, sym in ipairs(info.symbols or {}) do
				local name = type(sym) == "table" and sym[1] or sym
				if type(name) == "string" and (needle == "" or name:lower():find(needle, 1, true)) then
					table.insert(names, name)
				end
			end
			table.sort(names)
			vim.print(names)
		end, {
			nargs = "+",
			desc = "List treesitter node names for a language, optionally filtered",
		})
	end,
}

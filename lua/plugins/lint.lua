-- Linting for filetypes where the language server doesn't cover everything:
-- semantic linting for Verilog/SystemVerilog, syntax linting for VHDL.
return {
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

		-- nvim-lint ships no ghdl linter, so define one.
		--
		-- `-s` is syntax-only: it parses the file and exits without touching the
		-- work library, so it never writes .cf/.o files into your tree and never
		-- needs dependencies analysed first. Semantic errors come from vhdl_ls,
		-- which already elaborates the whole design.
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
		-- COOL has no language server, so lint by running the reference
		-- compiler. Change `cmd` if your course ships it under another name.
		--
		-- coolc drops output files (.s) in its working directory, so run it
		-- from a scratch dir instead of polluting your project.
		local cool_cmd = "/usr/class/bin/coolc"
		local cool_scratch = vim.fn.stdpath("cache") .. "/cool-lint"
		vim.fn.mkdir(cool_scratch, "p")

		lint.linters.cool = {
			cmd = cool_cmd,
			stdin = false,
			append_fname = true,
			stream = "both",
			ignore_exitcode = true,
			cwd = cool_scratch,
			parser = function(output, bufnr)
				local diagnostics = {}
				for line in vim.gsplit(output or "", "\n", { trimempty = true }) do
					-- Two formats the reference tools use:
					--   "foo.cl", line 5: syntax error at or near ...
					--   foo.cl:5: Class Foo was previously defined.
					local lnum, message = line:match('^"[^"]*", line (%d+): (.*)$')
					if not lnum then
						lnum, message = line:match("^[^:]+:(%d+): (.*)$")
					end
					if lnum then
						local row = tonumber(lnum) - 1
						-- No column info, so highlight the whole line.
						local text = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1] or ""
						table.insert(diagnostics, {
							lnum = row,
							col = 0,
							end_lnum = row,
							end_col = #text,
							severity = vim.diagnostic.severity.ERROR,
							source = "coolc",
							message = message,
						})
					end
				end
				return diagnostics
			end,
		}

		if vim.fn.executable(cool_cmd) == 1 then
			lint.linters_by_ft.cool = { "cool" }
		end
		-- Only wire ghdl up if it's actually on PATH, otherwise every save in a
		-- .vhd buffer produces a "command not found" notification.
		if vim.fn.executable("ghdl") == 1 then
			lint.linters_by_ft.vhdl = { "ghdl" }
		end

		local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

		vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
			group = lint_augroup,
			callback = function()
				-- Only run when a linter is configured for this filetype, so this
				-- doesn't fire on every InsertLeave in every buffer.
				if lint.linters_by_ft[vim.bo.filetype] then
					lint.try_lint()
				end
			end,
		})

		-- Debounced "as you type" linting for the HDL filetypes. Both verilator
		-- and ghdl read from disk rather than stdin, hence the forced write.
		--
		-- Note this overlaps with auto-save.nvim: it writes at 1000ms and that
		-- write already triggers the BufWritePost handler above. This block only
		-- buys you a faster (500ms) turnaround on HDL buffers -- delete it if the
		-- double writes bother you.
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
					lint.try_lint()
				end, 500)
			end,
		})
	end,
}

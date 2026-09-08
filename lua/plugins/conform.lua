-- Formatting. Manual only, via <leader>f.
return {
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

		-- Off deliberately: auto-save.nvim writes for you, and format-on-save
		-- plus autosave means the buffer gets rewritten while you're still
		-- typing. Use <leader>f.
		format_on_save = false,

		-- conform has no built-in vsg definition, so declare one. vsg (VHDL Style
		-- Guide) rewrites the file in place rather than writing to stdout, hence
		-- stdin = false and $FILENAME.
		--
		--   pipx install vsg
		--
		-- Rules are per-project via vsg_config.yaml; if you keep one at the
		-- project root use:
		--   args = { "--fix", "-c", "vsg_config.yaml", "-f", "$FILENAME" }
		formatters = {
			vsg = {
				command = "vsg",
				stdin = false,
				args = { "--fix", "-f", "$FILENAME" },
				-- vsg exits 1 when it found rule violations, including ones it just
				-- fixed. Without this, conform treats every fix as a failure.
				exit_codes = { 0, 1 },
			},
		},

		formatters_by_ft = {
			lua = { "stylua" },
			c = { "clang-format" },
			cpp = { "clang-format" },
			verilog = { "verible-verilog-format" },
			systemverilog = { "verible-verilog-format" },
			-- vsg if installed, otherwise whatever the attached LSP offers (recent
			-- VHDL-LS versions implement textDocument/formatting, older ones do
			-- nothing).
			vhdl = { "vsg", lsp_format = "fallback" },
			-- Rust goes through the LSP so rustfmt picks up the edition and
			-- rustfmt.toml from the Cargo project, which a bare `rustfmt` does not.
			rust = { lsp_format = "prefer" },
		},
	},
}

-- Autocompletion. See `:help blink-cmp`
return {
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
			opts = {},
		},
	},
	--- @module 'blink.cmp'
	--- @type blink.cmp.Config
	opts = {
		-- 'default' is <C-y> to accept, <C-n>/<C-p> to cycle, <C-space> to open.
		-- See `:help blink-cmp-config-keymap` for the other presets.
		keymap = { preset = "default" },

		appearance = { nerd_font_variant = "mono" },

		completion = {
			documentation = { auto_show = false, auto_show_delay_ms = 500 },
		},

		sources = {
			default = { "lsp", "path", "snippets" },
		},

		snippets = { preset = "luasnip" },

		-- The Rust matcher is faster; "lua" avoids the prebuilt-binary download.
		-- Switch to "prefer_rust_with_warning" if sorting ever feels sluggish.
		fuzzy = { implementation = "lua" },

		signature = { enabled = true },
	},
}

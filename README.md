# Neovim config

Kickstart-derived, restructured into the standard lazy.nvim layout.

```
init.lua                    leader keys, then requires the four config modules
lua/config/options.lua      vim.o settings, filetype mappings, diagnostics
lua/config/keymaps.lua      keymaps that don't belong to a plugin
lua/config/autocmds.lua     autocommands that don't belong to a plugin
lua/config/lazy.lua         bootstraps lazy.nvim, imports lua/plugins/
lua/plugins/*.lua           one plugin (or one tight group) per file
after/ftplugin/*.lua        per-filetype buffer options
after/queries/*/            treesitter query overrides
lazy-lock.json              pinned plugin revisions, commit this
```

## Adding a plugin

Drop a new file in `lua/plugins/` that returns a lazy spec. Nothing else needs
editing -- `lua/config/lazy.lua` imports the whole directory.

```lua
-- lua/plugins/example.lua
return {
	"owner/example.nvim",
	opts = {},
}
```

## Things installed outside Mason

| Tool          | Install                          |
| ------------- | -------------------------------- |
| rust-analyzer | `rustup component add rust-analyzer` |
| vhdl_ls       | AUR, or `cargo install vhdl_ls`  |
| ghdl          | `pacman -S ghdl` / `apt install ghdl` |
| vsg           | `pipx install vsg`               |
| verilator     | distro package                   |

Everything else comes from `mason-tool-installer`, configured at the bottom of
`lua/plugins/lsp.lua`.

## Useful commands

- `:Lazy` -- plugin status, update, profile startup
- `:Mason` -- tool installer UI
- `:ConformInfo` -- which formatters apply to this buffer
- `:checkhealth` -- diagnose a broken setup
- `:TSSymbols vhdl process` -- list treesitter node names, for writing queries

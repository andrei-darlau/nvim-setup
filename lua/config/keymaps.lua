-- [[ Keymaps ]]
-- Plugin-specific keymaps live with their plugin in lua/plugins/.
-- See `:help vim.keymap.set()`

local map = vim.keymap.set

-- Enter command mode without reaching for shift
map("n", ";", ":", { desc = "Enter command mode" })

-- Clear search highlighting
map("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Keep the selection after indenting
map("v", "<", "<gv", { desc = "Indent left and keep selection" })
map("v", ">", ">gv", { desc = "Indent right and keep selection" })

-- Exit terminal mode in the builtin terminal
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Window navigation
map("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
map("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
map("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
map("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

-- Move lines
map("n", "<A-Up>", "<cmd>m .-2<cr>==", { desc = "Move line up" })
map("n", "<A-Down>", "<cmd>m .+1<cr>==", { desc = "Move line down" })
map("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Move line up (hjkl)" })
map("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Move line down (hjkl)" })

-- Move the visual selection
map("v", "<A-Up>", ":m '<-2<cr>gv=gv", { desc = "Move block up" })
map("v", "<A-Down>", ":m '>+1<cr>gv=gv", { desc = "Move block down" })
map("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Move block up (hjkl)" })
map("v", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "Move block down (hjkl)" })

-- [[ Diagnostics ]]
map("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

-- Toggle between inline virtual text and full virtual lines. Handy in Rust,
-- where borrow-checker errors are far too long for end-of-line text.
map("n", "<leader>td", function()
	local cfg = vim.diagnostic.config()
	local to_lines = not cfg.virtual_lines
	vim.diagnostic.config({
		virtual_lines = to_lines and { current_line = true } or false,
		virtual_text = not to_lines,
	})
end, { desc = "[T]oggle [D]iagnostic virtual lines" })
map("n", "<Tab>", "i<Tab>", { desc = "Insert a literal tab" })


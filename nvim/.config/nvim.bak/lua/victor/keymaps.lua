-- Leader set up
vim.g.mapleader = " "

-- Close buffer with leaderQ
vim.keymap.set("n", "<leader>Q", ":bd<CR>")

-- Reselect visual selection after indenting
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

-- Open config
vim.keymap.set("n", "<leader>ve", ":e ~/.dotfiles/nvim/.config/nvim/init.lua<CR>")

-- Move between windows/buffers
vim.keymap.set("n", "<C-h>", "<C-w><C-h>")
vim.keymap.set("n", "<C-j>", "<C-w><C-j>")
vim.keymap.set("n", "<C-k>", "<C-w><C-k>")
vim.keymap.set("n", "<C-l>", "<C-w><C-l>")

-- Telescope
vim.keymap.set("n", "<leader>ff", ":Telescope find_files<CR>")
vim.keymap.set("n", "<leader>fff", ":Telescope find_files hidden=True<CR>")
vim.keymap.set("n", "<leader>fg", ":Telescope live_grep<CR>")
vim.keymap.set("n", "<leader>fk", ":Telescope keymaps<CR>")

-- Barbar
vim.keymap.set("n", "<Tab>", ":BufferNext<CR>", { desc = "Move to next tab" })
vim.keymap.set("n", "<S-Tab>", ":BufferPrevious<CR>", { desc = "Move to next tab" })

-- Misc
vim.keymap.set("n", "<leader>dark", ":set bg=dark<CR>", { desc = "Set BG to dark mode" })
vim.keymap.set("n", "<leader>light", ":set bg=light<CR>", { desc = "Set BG to light mode" })

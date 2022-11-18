-- Leader set up
vim.g.mapleader = " "
vim.g,maplocalleader = " "

-- Close buffer qith leaderQ
vim.keymap.set("n", "<leader>Q", ":bd<CR>")

-- Reselect visual selection after indenting
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

-- Open config
vim.keymap.set("n", "<leader>ve", ":e ~/.dotfiles/nvim/.config/nvim/init.lua")

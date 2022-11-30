-- My neovim config 
require("victor.keymaps")
require("victor.options")
require("victor.plugins")
require("victor.colorscheme")
require("victor.lualine")
require("victor.gitsigns")

-- Autocmd
-- cmd [[autocmd BufWritePre * :%s/\s\+$//e]] -- Delete trailing whitespaces

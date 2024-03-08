-- My neovim config
require("victor.keymaps")
require("victor.options")
require("victor.plugins")
require("victor.colorscheme")
require("victor.lualine")
require("victor.gitsigns")

require("victor.tree-sitter")
require("victor.lsp")
-- Autocmd
-- cmd [[autocmd BufWritePre * :%s/\s\+$//e]] -- Delete trailing whitespaces
-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

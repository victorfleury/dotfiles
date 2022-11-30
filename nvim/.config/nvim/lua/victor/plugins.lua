-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  -- Simple plugins can be specified as strings
  use 'nvim-treesitter/nvim-treesitter' --Syntax highlighting
  use 'sainnhe/everforest' -- Theme 
  use 'sheerun/vim-polyglot'
  use 'nvim-lua/plenary.nvim' -- Telescope dependencies
  use 'lewis6991/gitsigns.nvim' -- Git indicators
  use 'nvim-telescope/telescope.nvim' -- Fuzzy finder
  use 'BurntSushi/ripgrep' -- Needs to be installed via yum as well
  use 'pocco81/auto-save.nvim' -- Hello world
  use {
    'nvim-lualine/lualine.nvim',
    requires = { 'kyazdani42/nvim-web-devicons', opt = true }
  }
  use 'preservim/nerdcommenter' -- Commenter
end)

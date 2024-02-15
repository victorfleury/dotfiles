-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  -- Simple plugins can be specified as strings
  --use 'nvim-treesitter/nvim-treesitter' --Syntax highlighting
  use { -- LSP Configuration & Plugins
      'neovim/nvim-lspconfig',
      requires = {
        -- Automatically install LSPs to stdpath for neovim
        'williamboman/mason.nvim',
        'williamboman/mason-lspconfig.nvim',

        -- Useful status updates for LSP
        'j-hui/fidget.nvim',

        -- Additional lua configuration, makes nvim stuff amazing
        'folke/neodev.nvim',
      },
    }

    use { -- Autocompletion
      'hrsh7th/nvim-cmp',
      requires = { 'hrsh7th/cmp-nvim-lsp', 'L3MON4D3/LuaSnip', 'saadparwaiz1/cmp_luasnip' },
    }

    use { -- Highlight, edit, and navigate code
      'nvim-treesitter/nvim-treesitter',
      run = function()
        pcall(require('nvim-treesitter.install').update { with_sync = true })
      end,
    }

    use { -- Additional text objects via treesitter
      'nvim-treesitter/nvim-treesitter-textobjects',
      after = 'nvim-treesitter',
    }

  -- Simple plugins can be specified as strings
  --use 'nvim-treesitter/nvim-treesitter' --Syntax highlighting
  use 'sainnhe/everforest' -- Theme 
  use 'sheerun/vim-polyglot'
  use 'nvim-lua/plenary.nvim' -- Telescope dependencies
  use 'tpope/vim-fugitive' -- Fugitive
  use 'lewis6991/gitsigns.nvim' -- Git indicators
  use 'nvim-telescope/telescope.nvim' -- Fuzzy finder
  use 'BurntSushi/ripgrep' -- Needs to be installed via yum as well
  use 'pocco81/auto-save.nvim' -- Hello world
  use 'kyazdani42/nvim-web-devicons' -- fancy icons
  use {
    'nvim-lualine/lualine.nvim',
    requires = { 'kyazdani42/nvim-web-devicons', opt = true }
  }
  use 'preservim/nerdcommenter' -- Commenter
  use {'romgrk/barbar.nvim', wants = 'nvim-web-devicons'} -- tabs
  use {
    "windwp/nvim-autopairs",
    config = function() require("nvim-autopairs").setup {} end
  }

  use 'jiangmiao/auto-pairs'



  -- Debug Adapter Protocol : DAP
  use 'mfussenegger/nvim-dap'
  use 'mfussenegger/nvim-dap-python'
  use 'rcarriga/nvim-dap-ui'
end)

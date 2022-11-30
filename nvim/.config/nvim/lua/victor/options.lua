-- Options !
local options = {
    syntax = 'on', -- syntax color highlighting
    background = 'light', -- adjust color background
    swapfile = false,
    backup = false,
    writebackup = false,
    hidden = true,
    shiftwidth = 4,
    tabstop = 4,
    softtabstop = 4,
    expandtab = true,
    smartindent = true,
    autoindent = true,
    number = true,
    relativenumber = true,
    numberwidth = 4,
    ruler = true,
    colorcolumn = "80",
    title = true,
    termguicolors = true,
    spell = true,
    ignorecase = true,
    smartcase = true,
    wrap = false,
    breakindent = true, -- maintain indent when wrapping indented lines
    list = true, -- enable the below listchars
    listchars = { tab = '▸ ', space = '·', trail = '·' },
    mouse = 'a', -- enable mouse for all modes
    splitbelow = true,
    splitright = true,
    scrolloff = 8,
    sidescrolloff = 8,
    clipboard = 'unnamedplus', -- Use Linux system clipboard
    confirm = true, -- ask for confirmation instead of erroring
    undofile = true, -- persistent undo
    wildignore = '*.o,*~,*.pyc',
    wildmode = 'longest:full,full', -- complete the longest common match, and allow tabbing the results to fully complete them
    --signcolumn = 'yes:2',
    showmode = false,
    updatetime = 4001, -- Set updatime to 1ms longer than the default to prevent polyglot from changing it
    redrawtime = 10000, -- Allow more time for loading syntax on large files
}

for k, v in pairs(options) do
    vim.opt[k] = v
end

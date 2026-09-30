local opt = vim.opt

vim.g.mapleader = ' '
vim.g.maplocalleader = ','

opt.colorcolumn = "80"                             -- Highlight column 80
opt.termguicolors = true                           -- Enable true colors
opt.background = 'dark'
opt.winborder = "rounded"                          -- Use rounded borders for windows

opt.ignorecase = true                              -- Ignore case in search
opt.smartcase = true                               -- Use case-sensitive search when uppercase is present
opt.hlsearch = false                               -- Disable highlighting of search results
opt.incsearch = true                               -- Show matches while searching

opt.swapfile = false                               -- Disable swap files

opt.autoindent = true                              -- Enable auto indentation
opt.expandtab = true                               -- Use spaces instead of tabs
opt.tabstop = 4                                    -- Number of spaces for a tab
opt.softtabstop = 4                                -- Number of spaces for a tab when editing
opt.shiftwidth = 4                                 -- Number of spaces for autoindent
opt.shiftround = true                              -- Round indent to multiple of shiftwidth

opt.list = true                                    -- Show whitespace characters
opt.number = true                                  -- Show line numbers
opt.relativenumber = true                          -- Show relative line numbers
opt.numberwidth = 2                                -- Width of the line number column
opt.signcolumn = 'yes'                             -- Keep the sign column stable
opt.wrap = false                                   -- Disable line wrapping
opt.cursorline = true                              -- Highlight the current line
opt.scrolloff = 8                                  -- Keep 8 lines above and below the cursor
opt.splitbelow = true                               -- Open horizontal splits below
opt.splitright = true                               -- Open vertical splits to the right

local undo_dir = vim.fn.stdpath('state') .. '/undo'
vim.fn.mkdir(undo_dir, 'p')                         -- Ensure the undo directory exists
opt.undodir = undo_dir                              -- Directory for undo files
opt.undofile = true                                -- Enable persistent undo


-- Use ripgrep for :grep
opt.grepprg = 'rg --vimgrep --smart-case'
opt.grepformat = '%f:%l:%c:%m'

opt.autocomplete = true
opt.completeopt = { "menuone", "popup", "noinsert" } -- Options for completion menu

vim.cmd.filetype("plugin indent on")                 -- Enable filetype detection, plugins, and indentation

local two_space_filetypes = vim.api.nvim_create_augroup('TwoSpaceIndent', { clear = true })
vim.api.nvim_create_autocmd('FileType', {
    group = two_space_filetypes,
    pattern = { 'lua', 'nix', 'toml', 'typst' },
    callback = function()
        vim.opt_local.tabstop = 2
        vim.opt_local.softtabstop = 2
        vim.opt_local.shiftwidth = 2
    end,
})

opt.clipboard = 'unnamedplus'


-- Diagnostics
vim.diagnostic.config({
    virtual_text = true,
    underline = true,
    severity_sort = true,
    float = { border = 'rounded' },
})





local yank_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })

vim.api.nvim_create_autocmd('TextYankPost', {
    group = yank_group,
    pattern = '*',
    callback = function()
        vim.highlight.on_yank({ timeout = 170 })
    end,
})

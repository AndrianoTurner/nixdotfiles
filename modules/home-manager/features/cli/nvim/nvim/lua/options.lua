local opt = vim.opt

vim.g.mapleader = ' '

opt.colorcolumn = "80"                             -- Highlight column 80
opt.termguicolors = true                           -- Enable true colors
opt.background = 'dark'
opt.winborder = "rounded"                          -- Use rounded borders for windows

opt.ignorecase = true                              -- Ignore case in search
opt.hlsearch = false                               -- Disable highlighting of search results

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
opt.wrap = false                                   -- Disable line wrapping
opt.cursorline = true                              -- Highlight the current line
opt.scrolloff = 8                                  -- Keep 8 lines above and below the cursor

opt.undodir = os.getenv('HOME') .. '/.vim/undodir' -- Directory for undo files
opt.undofile = true                                -- Enable persistent undo


-- Use ripgrep for :grep
opt.grepprg = 'rg --vimgrep --smart-case'
opt.grepformat = '%f:%l:%c:%m'

opt.autocomplete = true
opt.completeopt = { "menuone", "popup", "noinsert" } -- Options for completion menu

vim.cmd.filetype("plugin indent on")                 -- Enable filetype detection, plugins, and indentation

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



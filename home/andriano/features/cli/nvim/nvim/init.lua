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

vim.pack.add({
    { src = 'https://github.com/echasnovski/mini.nvim',    version = 'main' },
    { src = 'https://github.com/ellisonleao/gruvbox.nvim', version = 'main' },
    { src = 'https://github.com/saghen/blink.cmp',         version = vim.version.range('^1') },
    { src = 'https://github.com/lewis6991/gitsigns.nvim' },
}, {
    confirm = false,
    load = true,
})

require('gitsigns').setup({ signcolumn = false })

require('blink.cmp').setup({
    fuzzy = { implementation = 'prefer_rust_with_warning' },
    signature = { enabled = true },
    completion = {
        documentation = {
            auto_show = true,
            auto_show_delay_ms = 200,
        },
    },
    sources = { default = { 'lsp' } },
})

require('gruvbox').setup({
    terminal_colors = true,
    undercurl = true,
    underline = true,
    bold = true,
    italic = {
        strings = true,
        emphasis = true,
        comments = true,
        operators = false,
        folds = true,
    },
    contrast = 'hard',
    transparent_mode = true,

    -- Extra transparency fixes for common UI surfaces.
    overrides = {
        Normal = { bg = 'NONE' },
        NormalNC = { bg = 'NONE' },
        NormalFloat = { bg = 'NONE' },
        FloatBorder = { bg = 'NONE' },
        SignColumn = { bg = 'NONE' },
        FoldColumn = { bg = 'NONE' },
        LineNr = { bg = 'NONE' },
        CursorLineNr = { bg = 'NONE' },
        EndOfBuffer = { bg = 'NONE' },
        StatusLine = { bg = 'NONE' },
        StatusLineNC = { bg = 'NONE' },
        TabLine = { bg = 'NONE' },
        TabLineFill = { bg = 'NONE' },
        WinSeparator = { bg = 'NONE' },
    },
})

-- Diagnostics
vim.diagnostic.config({
    virtual_text = true,
    underline = true,
    severity_sort = true,
    float = { border = 'rounded' },
})

vim.cmd.colorscheme('gruvbox')

require('mini.pick').setup()
require('mini.files').setup()
require('mini.statusline').setup()

--- KEYMAP
---
local keymap = vim.keymap.set

keymap('n', '<leader>ps', function()
    vim.pack.update()
end, { desc = 'Update plugins' })

keymap('n', '<leader>f', '<cmd>Pick files<cr>', { desc = 'Find files' })
keymap('n', '<leader>g', '<cmd>Pick grep_live<cr>', { desc = 'Live grep' })
keymap('n', '<leader>e', '<cmd>lua MiniFiles.open()<cr>', { desc = 'File explorer' })

-- Built-in 0.12 commands
keymap('n', '<leader>u', '<cmd>Undotree<cr>', { desc = 'Undo tree' })
keymap('n', '<leader>d', '<cmd>DiffTool<cr>', { desc = 'Diff tool' })


keymap('n', '<leader>xq', vim.diagnostic.setqflist, { desc = 'Diagnostics quickfix' })
keymap('n', '[d', function() vim.diagnostic.jump({ count = -1 }) end, { desc = 'Prev diagnostic' })
keymap('n', ']d', function() vim.diagnostic.jump({ count = 1 }) end, { desc = 'Next diagnostic' })

keymap('n', '<C-d>', '<C-d>zz', { desc = 'Scroll down and center' })
keymap('n', '<C-u>', '<C-u>zz', { desc = 'Scroll up and center' })
keymap('n', '<C-s>', '<cmd>w!<CR>', { silent = true, desc = 'Save file' })
keymap('n', '<Leader>qq', '<cmd>q<CR>', { silent = true, desc = 'Quit' })
keymap('n', '<Leader>te', '<cmd>tabnew<CR>', { silent = true, desc = 'New tab' })
keymap('n', '<Leader>_', '<cmd>vsplit<CR>', { silent = true, desc = 'Vertical split' })
keymap('n', '<Leader>-', '<cmd>split<CR>', { silent = true, desc = 'Horizontal split' })
keymap('n', '<Leader>lf', function()
    vim.lsp.buf.format()
end, { silent = true, desc = 'Format buffer' })
keymap('v', '<Leader>p', '"_dP', { desc = 'Paste without yanking' })
keymap('x', 'y', [["+y]], { silent = true, desc = 'Yank to clipboard' })
keymap('t', '<Esc>', '<C-\\><C-N>', { desc = 'Exit terminal mode' })
-- Change directory to the current file's directory
keymap('n', '<leader>cd', function()
    vim.fn.chdir(vim.fn.expand('%:p:h'))
end, { desc = 'CD to file directory' })

local miniclue = require('mini.clue')

miniclue.setup({
    -- Show the popup quickly after pressing <Leader>.
    delay = 0,

    triggers = {
        { mode = 'n', keys = '<Leader>' },
        { mode = 'x', keys = '<Leader>' },

        { mode = 'n', keys = 'g' },
        { mode = 'x', keys = 'g' },

        { mode = 'n', keys = '[' },
        { mode = 'n', keys = ']' },

        { mode = 'n', keys = '<C-w>' },
        { mode = 'n', keys = '"' },
        { mode = 'x', keys = '"' },
        { mode = 'i', keys = '<C-r>' },
        { mode = 'c', keys = '<C-r>' },
    },

    clues = {
        miniclue.gen_clues.g(),
        miniclue.gen_clues.windows(),
        miniclue.gen_clues.registers(),
        miniclue.gen_clues.builtin_completion(),

        -- Leader groups. Terminal mappings like <Leader>f / <Leader>g
        -- are picked up automatically from their `desc`.
        { mode = 'n', keys = '<Leader>c', desc = '+code/cd' },
        { mode = 'n', keys = '<Leader>l', desc = '+lsp' },
        { mode = 'n', keys = '<Leader>p', desc = '+plugins' },
        { mode = 'n', keys = '<Leader>q', desc = '+quit' },
        { mode = 'n', keys = '<Leader>t', desc = '+tabs' },
        { mode = 'n', keys = '<Leader>x', desc = '+diagnostics' },
    },
})

--- KEYMAP
-- Global LSP defaults
vim.lsp.config('*', {
    root_markers = { '.git' },
})

-- Rust
vim.lsp.config('rust_analyzer', {
    cmd = { 'rust-analyzer' },
    filetypes = { 'rust' },
    root_markers = { 'Cargo.toml', 'rust-project.json', '.git' },
    settings = {
        ['rust-analyzer'] = {
            cargo = { allFeatures = true },
            check = { command = 'clippy' },
        },
    },
})

-- Nix
vim.lsp.config('nil_ls', {
    cmd = { 'nil' },
    filetypes = { 'nix' },
    root_markers = { 'flake.nix', 'default.nix', '.git' },
    settings = {
        ['nil'] = {
            formatting = {
                command = { 'nixfmt' },
            },
        },
    },
})

-- Lua
vim.lsp.config('lua_ls', {
    cmd = { 'lua-language-server' },
    filetypes = { 'lua' },
    root_markers = { '.luarc.json', '.luarc.jsonc', '.git' },
    settings = {
        Lua = {
            runtime = { version = 'LuaJIT' },
            diagnostics = {
                globals = { 'vim' },
            },
            workspace = {
                library = vim.api.nvim_get_runtime_file('', true),
            },
        },
    },
})

-- TOML
vim.lsp.config('taplo', {
    cmd = { 'taplo', 'lsp', 'stdio' },
    filetypes = { 'toml' },
    root_markers = { 'taplo.toml', 'Cargo.toml', '.git' },
})

vim.lsp.enable({
    'rust_analyzer',
    'nil_ls',
    'lua_ls',
    'taplo',
})

vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(ev)
        local client = assert(vim.lsp.get_client_by_id(ev.data.client_id))
        local buf = ev.buf

        local map = function(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = desc })
        end

        map('n', 'gd', vim.lsp.buf.definition, 'Go to definition')
        map('n', 'gD', vim.lsp.buf.declaration, 'Go to declaration')
        map('n', 'gr', vim.lsp.buf.references, 'References')
        map('n', 'gi', vim.lsp.buf.implementation, 'Implementation')
        map('n', '<leader>rn', vim.lsp.buf.rename, 'Rename')
        map({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, 'Code action')
        map('n', '<leader>lf', function()
            vim.lsp.buf.format({ bufnr = buf, timeout_ms = 1000 })
        end, 'Format')


        if client:supports_method('textDocument/inlayHint') then
            vim.lsp.inlay_hint.enable(true, { bufnr = buf })
        end
    end,
})

local yank_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })

vim.api.nvim_create_autocmd('TextYankPost', {
    group = yank_group,
    pattern = '*',
    callback = function()
        vim.highlight.on_yank({ timeout = 170 })
    end,
})

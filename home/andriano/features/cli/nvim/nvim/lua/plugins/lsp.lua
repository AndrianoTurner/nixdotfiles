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

-- Typst
vim.lsp.config("tinymist", {

    cmd = { "tinymist" },

    filetypes = { "typst" },

    settings = {
--        exportPdf = "onType",
        lint = {
            enabled = true,
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
    'tinymist'
})

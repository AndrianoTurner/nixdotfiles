


require('conform').setup({
  rust = { "rustfmt", lsp_format = "fallback" },
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


vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function(args)
    require("conform").format({ bufnr = args.buf })
  end,
})




require('conform').setup({
  formatters_by_ft = {
    rust = { "rustfmt", lsp_format = "fallback" },
  },
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


local format_group = vim.api.nvim_create_augroup("FormatOnSave", { clear = true })

vim.api.nvim_create_autocmd("BufWritePre", {
  group = format_group,
  pattern = "*",
  callback = function(args)
    if vim.bo[args.buf].buftype ~= "" then
      return
    end

    local conform = require("conform")
    local formatters, has_lsp = conform.list_formatters_to_run(args.buf)
    if #formatters == 0 and not has_lsp then
      return
    end

    conform.format({
      bufnr = args.buf,
      lsp_format = "fallback",
    })
  end,
})

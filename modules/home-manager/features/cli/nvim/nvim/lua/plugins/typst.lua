

require('typst-preview').setup({
    dependencies_bin = {
        tinymist = vim.fn.exepath('tinymist'),
        websocat = vim.fn.exepath('websocat'),
    },

    open_cmd = 'zen-beta %s',

    host = '127.0.0.1',
    port = 0,
})

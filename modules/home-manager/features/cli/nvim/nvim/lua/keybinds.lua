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


--- KEYMAP

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


vim.api.nvim_create_user_command("OpenPdf", function()

    local filepath = vim.api.nvim_buf_get_name(0)

    if filepath:match("%.typ$") then

        local pdf_path = filepath:gsub("%.typ$", ".pdf")

        vim.system({ "evince", pdf_path })

    end

end, {})

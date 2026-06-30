


require('mini.files').setup()
require('mini.statusline').setup()
require('mini.pick').setup()


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

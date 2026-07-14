

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


vim.cmd.colorscheme('gruvbox')

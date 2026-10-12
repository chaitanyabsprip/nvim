local tools = {}

---@module "lazy"
---@type LazySpec[]
tools.spec = {
    {
        'catgoose/nvim-colorizer.lua',
        cmd = { 'ColorizerAttachToBuffer', 'ColorizerToggle' },
        event = 'BufWinEnter',
        opts = {
            filetypes = { '*', '!lazy' },
            buftypes = { '*', '!prompt', '!nofile' },
            options = {
                parsers = {
                    css_fn = true,
                    names = { enable = false },
                    hex = { default = true },
                    tailwind = {
                        enable = false,
                        update_names = false, -- feed LSP colors back into name parser (requires both enable + lsp.enable)
                        lsp = {
                            enable = false, -- use Tailwind LSP documentColor
                            disable_document_color = true, -- auto-disable vim.lsp.document_color on attach
                        },
                    },
                },
                display = {
                    mode = 'backgound',
                    virtualtext = {
                        char = '███', -- character used for virtualtext
                        position = 'eol', -- "eol"|"before"|"after"
                        hl_mode = 'foreground', -- "background"|"foreground"
                    },
                },
            },
        },
    },
    {
        'toppair/peek.nvim',
        build = 'deno task --quiet build:fast',
        keys = {
            {
                '<leader>op',
                function()
                    local peek = require 'peek'
                    if peek.is_open() then
                        peek.close()
                    else
                        peek.open()
                    end
                end,
                desc = 'Peek (Markdown Preview)',
            },
        },
        opts = { app = 'browser' },
    },
    {
        'dstein64/vim-startuptime',
        config = function() vim.g.startuptime_tries = 50 end,
        cmd = 'StartupTime',
    },
    {
        'christoomey/vim-tmux-navigator',
        cmd = {
            'TmuxNavigateLeft',
            'TmuxNavigateDown',
            'TmuxNavigateUp',
            'TmuxNavigateRight',
            'TmuxNavigatePrevious',
        },
        event = 'VeryLazy',
        keys = {
            { '<c-h>', '<cmd><C-U>TmuxNavigateLeft<cr>' },
            { '<c-j>', '<cmd><C-U>TmuxNavigateDown<cr>' },
            { '<c-k>', '<cmd><C-U>TmuxNavigateUp<cr>' },
            { '<c-l>', '<cmd><C-U>TmuxNavigateRight<cr>' },
            { '<c-\\>', '<cmd><C-U>TmuxNavigatePrevious<cr>' },
        },
    },
    {
        'fladson/vim-kitty',
        ft = 'kitty',
    },
    {
        'folke/zen-mode.nvim',
        opts = { plugins = { twilight = { enabled = false } } },
        cmd = { 'ZenMode' },
        keys = {
            {
                'gz',
                function() require('zen-mode').toggle() end,
                desc = 'Toggle Zen Mode',
                mode = { 'n' },
            },
            {
                '<c-w>z',
                function() require('zen-mode').toggle() end,
                desc = 'Toggle Zen Mode',
                mode = { 'n' },
            },
        },
    },
    {
        'folke/twilight.nvim',
        opts = {},
        cmd = { 'Twilight', 'TwilightEnable', 'TwilightDisable' },
    },
    {
        'hat0uma/csvview.nvim',
        ---@module "csvview"
        ---@type CsvView.Options
        opts = {
            parser = { comments = { '#', '//' } },
            keymaps = {
                -- Text objects for selecting fields
                textobject_field_inner = {
                    'if',
                    mode = { 'o', 'x' },
                    buffer = true,
                },
                textobject_field_outer = {
                    'af',
                    mode = { 'o', 'x' },
                    buffer = true,
                },
                jump_next_field_end = {
                    'L',
                    mode = { 'n', 'v' },
                    buffer = true,
                },
                jump_prev_field_end = {
                    'H',
                    mode = { 'n', 'v' },
                    buffer = true,
                },
                jump_next_row = {
                    'J',
                    mode = { 'n', 'v' },
                    buffer = true,
                },
                jump_prev_row = {
                    'K',
                    mode = { 'n', 'v' },
                    buffer = true,
                },
            },
        },
        cmd = { 'CsvViewEnable', 'CsvViewDisable', 'CsvViewToggle' },
    },
}

return tools.spec

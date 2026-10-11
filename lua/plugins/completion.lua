---@diagnostic disable: no-unknown
---@module "lazy"
---@type LazySpec[] | function
return {
    {
        'saghen/blink.cmp',
        dependencies = { { 'rafamadriz/friendly-snippets' } },
        version = '1.*',
        event = { 'InsertEnter', 'CmdlineEnter' },
        ---@module 'blink.cmp'
        ---@type blink.cmp.Config
        opts = {
            keymap = { preset = 'default' },
            appearance = { nerd_font_variant = 'mono' },
            completion = {
                documentation = { auto_show = true, window = { border = 'none' } },
                menu = {
                    border = 'rounded',
                    draw = {
                        padding = { 0, 1 }, -- padding only on right side
                        components = {
                            kind_icon = {
                                text = function(ctx)
                                    return ' ' .. ctx.kind_icon .. ctx.icon_gap .. ' '
                                end,
                            },
                        },
                    },
                },
            },
            sources = {
                default = { 'lsp', 'path', 'snippets', 'buffer' },
                per_filetype = {
                    sql = { inherit_defaults = true, 'dadbod' },
                },
                providers = {
                    lsp = { fallbacks = {} }, -- defaults to `{ 'buffer' }`
                    dadbod = { module = 'vim_dadbod_completion.blink' },
                },
            },
            fuzzy = { implementation = 'prefer_rust_with_warning' },
            cmdline = {
                completion = { menu = { auto_show = true } },
                sources = function()
                    local type = vim.fn.getcmdtype()
                    if type == '/' or type == '?' then return { 'buffer' } end
                    return { 'lsp', 'path', 'cmdline' }
                end,
            },
            signature = {
                enabled = true,
                window = { show_documentation = true, border = 'none' },
            },
        },
    },
    { 'Alexisvt/flutter-snippets', ft = { 'dart' } },
    { 'Nash0x7E2/awesome-flutter-snippets', ft = { 'dart' } },
    { 'natebosch/dartlang-snippets', ft = 'dart' },
    -- {
    --     'copilotlsp-nvim/copilot-lsp',
    --     event = 'InsertEnter',
    --     config = function()
    --         vim.g.copilot_nes_debounce = 500
    --         vim.lsp.enable 'copilot_ls'
    --         vim.keymap.set(
    --             'n',
    --             '<c-c>',
    --             function()
    --                 local _ = require('copilot-lsp.nes').walk_cursor_start_edit()
    --                     or (
    --                         require('copilot-lsp.nes').apply_pending_nes()
    --                         and require('copilot-lsp.nes').walk_cursor_end_edit()
    --                     )
    --             end
    --         )
    --         vim.keymap.set('n', '<esc>', function()
    --             if not require('copilot-lsp.nes').clear() then _ = '' end
    --         end, { desc = 'Clear Copilot suggestion or fallback' })
    --         require('copilot-lsp').setup {}
    --     end,
    -- },
    {
        'CopilotC-Nvim/CopilotChat.nvim',
        enabled = false,
        dependencies = {
            { 'zbirenbaum/copilot.lua' },
            -- { 'github/copilot.vim' }, -- or zbirenbaum/copilot.lua
            { 'nvim-lua/plenary.nvim' }, -- for curl, log wrapper
        },
        build = 'make tiktoken', -- Only on MacOS or Linux
        keys = {
            {
                '<leader>cc',
                '<cmd>CopilotChatToggle<cr>',
                desc = 'Copilot Chat',
                mode = { 'n', 'v' },
                noremap = true,
                silent = true,
            },
        },
        cmd = {
            'CopilotChat',
            'CopilotChatOpen',
            'CopilotChatClose',
            'CopilotChatToggle',
            'CopilotChatStop',
            'CopilotChatReset',
            'CopilotChatSave',
            'CopilotChatLoad',
            'CopilotChatDebugInfo',
            'CopilotChatModels',
            'CopilotChatAgents',
        },
    },
    {
        'zbirenbaum/copilot.lua',
        enabled = false,
        event = 'InsertEnter',
        dependencies = { 'copilotlsp-nvim/copilot-lsp' },
        opts = {
            panel = { enabled = false, auto_refresh = true },
            suggestion = {
                auto_trigger = true,
                keymap = {
                    accept = '<C-a>',
                    accept_word = false,
                    accept_line = false,
                    next = '<M-]>',
                    prev = '<M-[>',
                    dismiss = '<C-]>',
                },
            },
            nes = {
                enabled = true,
                auto_trigger = true,
                keymap = {
                    accept_and_goto = '<c-c>',
                    dismiss = '<esc>',
                },
            },
            -- copilot_model = 'gpt-41-copilot',
        },
    },
    -- blink's own capabilities on top of the nvim defaults, so servers actually
    -- hear about the completion features it implements
    get_capabilities = function(override)
        return require('blink.cmp').get_lsp_capabilities(override)
    end,
}

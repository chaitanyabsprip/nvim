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
                    border = 'none',
                    draw = {
                        padding = { 0, 1 },
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
        },
    },
    -- blink's own capabilities on top of the nvim defaults, so servers actually
    -- hear about the completion features it implements
    get_capabilities = function(override)
        return require('blink.cmp').get_lsp_capabilities(override)
    end,
}

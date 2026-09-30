---@type LazyPluginSpec[]
return {
    {
        'williamboman/mason.nvim',
        optional = true,
        opts = function(_, opts)
            require('config.lazy').extend_opts_list(opts, 'ensure_installed', 'dotenv-linter')
        end,
    },
    {
        'nvim-treesitter/nvim-treesitter',
        optional = true,
        opts = function(_, opts)
            require('config.lazy').extend_opts_list(opts, 'ensure_installed', 'dotenv')
            -- local parser_config = require('nvim-treesitter.parsers').get_parser_configs()
            -- parser_config['dotenv'] = {
            --     install_info = {
            --         url = 'https://github.com/pnx/tree-sitter-dotenv',
            --         branch = 'main',
            --         files = { 'src/parser.c', 'src/scanner.c' },
            --     },
            --     filetype = 'dotenv',
            -- }
        end,
    },
    {
        'nvimtools/none-ls.nvim',
        optional = true,
        ft = function(_, filetypes) return vim.list_extend(filetypes, { 'dotenv' }) end,
        opts = function(_, opts)
            require('config.lazy').extend_opts_list(
                opts,
                'sources',
                ---@param builtins NullBuiltin
                function(builtins)
                    return {
                        builtins.diagnostics.dotenv_linter.with {
                            filetypes = { 'dotenv' },
                            -- dotenv-linter v4 moved linting behind the `check` subcommand
                            args = { 'check', '--plain', '-q', '$FILENAME' },
                        },
                    }
                end
            )
        end,
    },
}

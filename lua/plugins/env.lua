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

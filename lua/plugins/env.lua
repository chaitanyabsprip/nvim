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
            -- not a grammar nvim-treesitter ships; config registers it before
            -- install() asks for it
            opts.parsers = opts.parsers or {}
            opts.parsers.dotenv = {
                install_info = { url = 'https://github.com/pnx/tree-sitter-dotenv' },
                tier = 3,
            }
            require('config.lazy').extend_opts_list(opts, 'ensure_installed', 'dotenv')
        end,
        -- nvim detects .env as filetype `env`; the grammar is called `dotenv`,
        -- so the shared ensure_installed -> FileType wiring cannot match it
        init = function()
            vim.treesitter.language.register('dotenv', 'env')
            vim.api.nvim_create_autocmd('FileType', {
                group = vim.api.nvim_create_augroup('dotenv', { clear = true }),
                pattern = 'env',
                callback = function() pcall(vim.treesitter.start) end,
            })
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

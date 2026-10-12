local configure = require('plugins.lsp').configure

local function marksman() configure('marksman', { root = { '.marksman.toml' } }) end
local function oxide() configure('markdown_oxide', {}) end

---@module "lazy"
---@type LazySpec[]
return {
    {
        'nvim-treesitter/nvim-treesitter',
        optional = true,
        opts = function(_, opts)
            require('config.lazy').extend_opts_list(
                opts,
                'ensure_installed',
                'markdown',
                'markdown_inline'
            )
        end,
    },
    {
        'williamboman/mason.nvim',
        optional = true,
        opts = function(_, opts)
            require('config.lazy').extend_opts_list(
                opts,
                'ensure_installed',
                'ltex-ls',
                'markdownlint',
                'markdown-oxide',
                'marksman'
            )
        end,
    },
    {
        'nvimtools/none-ls.nvim',
        optional = true,
        ft = function(_, filetypes)
            return vim.list_extend(filetypes, { 'markdown', 'md', 'rmd', 'rst' })
        end,
        opts = function(_, opts)
            require('config.lazy').extend_opts_list(
                opts,
                'sources',
                ---@param builtins NullBuiltin
                function(builtins)
                    return {
                        builtins.formatting.markdownlint,
                        builtins.diagnostics.markdownlint.with {
                            extra_args = { '--disable', 'MD024' },
                        },
                        builtins.hover.dictionary,
                    }
                end
            )
        end,
    },
    {
        'neovim/nvim-lspconfig',
        optional = true,
        opts = { servers = { marksman = marksman, oxide = oxide } },
    },
    {
        'OXY2DEV/markview.nvim',
        ft = { 'markdown', 'md', 'rmd', 'rst' },
        opts = {},
        dependencies = {
            'nvim-treesitter/nvim-treesitter',
            'nvim-tree/nvim-web-devicons',
        },
    },
}

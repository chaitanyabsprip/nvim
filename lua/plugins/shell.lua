local configure = require('plugins.lsp').configure
local function bashls() configure('bashls', { filetypes = { 'bash', 'sh', 'zsh' } }) end
local function awkls() configure('awk_ls', {}) end

return {
    ---@type LazyPluginSpec
    {
        'nvim-treesitter/nvim-treesitter',
        optional = true,
        opts = function(_, opts)
            require('config.lazy').extend_opts_list(
                opts,
                'ensure_installed',
                'bash',
                'fish',
                'ssh_config'
            )
        end,
    },
    ---@type LazyPluginSpec
    {
        'williamboman/mason.nvim',
        optional = true,
        opts = function(_, opts)
            require('config.lazy').extend_opts_list(
                opts,
                'ensure_installed',
                'bash-language-server',
                'shfmt',
                'shellcheck',
                'awk-language-server'
            )
        end,
    },
    ---@type LazyPluginSpec
    {
        'nvimtools/none-ls.nvim',
        ft = function(_, filetypes)
            return vim.list_extend(filetypes, { 'bash', 'fish', 'sh', 'zsh' })
        end,
        optional = true,
        opts = function(_, opts)
            require('config.lazy').extend_opts_list(
                opts,
                'sources',
                ---@param builtins NullBuiltin
                function(builtins)
                    return {
                        vim.fn.executable 'zsh' and builtins.diagnostics.zsh,
                        vim.fn.executable 'fish_indent' and builtins.formatting.fish_indent,
                        builtins.formatting.shfmt.with { filetypes = { 'zsh', 'bash', 'sh' } },
                    }
                end
            )
        end,
    },
    ---@type LazyPluginSpec
    {
        'neovim/nvim-lspconfig',
        optional = true,
        opts = { servers = { bashls = bashls, awkls = awkls } },
    },
    ---@type LazyPluginSpec
    {
        'dag/vim-fish',
        ft = 'fish',
        cond = function() return vim.uv.fs_stat 'config.fish' end,
    },
}

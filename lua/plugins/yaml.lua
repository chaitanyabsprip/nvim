local configure = require('plugins.lsp').configure

local function yamlls()
    local config = {
        settings = {
            redhat = { telemetry = false },
            yaml = {
                schemaStore = {
                    enable = true,
                    url = 'https://www.schemastore.org/api/json/catalog.json',
                },
                format = { singleQuote = true },
            },
        },
    }
    configure('yamlls', config)
end

return {
    ---@type LazyPluginSpec
    {
        'nvim-treesitter/nvim-treesitter',
        optional = true,
        opts = function(_, opts)
            require('config.lazy').extend_opts_list(opts, 'ensure_installed', 'yaml')
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
                'yaml-language-server',
                -- 'prettier',
                'yamllint'
            )
        end,
    },
    ---@type LazyPluginSpec
    {
        'nvimtools/none-ls.nvim',
        ft = function(_, filetypes)
            return vim.list_extend(filetypes, { 'yaml', 'yaml.docker-compose' })
        end,
        optional = true,
        opts = function(_, opts)
            require('config.lazy').extend_opts_list(
                opts,
                'sources',
                ---@param builtins NullBuiltin
                function(builtins)
                    return {
                        builtins.diagnostics.yamllint,
                        builtins.formatting.prettier.with { filetypes = { 'yaml' } },
                    }
                end
            )
        end,
    },
    ---@type LazyPluginSpec
    {
        'neovim/nvim-lspconfig',
        optional = true,
        opts = { servers = { yamlls = yamlls } },
    },
}

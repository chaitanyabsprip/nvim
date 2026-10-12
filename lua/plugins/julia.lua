local configure = require('plugins.lsp').configure

local function julials() configure 'julials' end

---@type LazyPluginSpec[]
return {
    {
        'nvim-treesitter/nvim-treesitter',
        optional = true,
        opts = function(_, opts)
            require('config.lazy').extend_opts_list(opts, 'ensure_installed', 'julia')
        end,
    },
    {
        'neovim/nvim-lspconfig',
        optional = true,
        opts = { servers = { julials = julials } },
    },
}

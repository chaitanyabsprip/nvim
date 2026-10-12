---@diagnostic disable: no-unknown

local function install(pkg, version)
    vim.notify(('installing %s'):format(pkg.name), vim.log.levels.INFO)
    return pkg:install({ version = version }):once(
        'closed',
        vim.schedule_wrap(function()
            if pkg:is_installed() then
                vim.notify(('%s was successfully installed'):format(pkg.name))
            else
                vim.notify(
                    ('failed to install %s. Installation logs are available in :Mason and :MasonLog'):format(
                        pkg.name
                    ),
                    vim.log.levels.ERROR
                )
            end
        end)
    )
end

local function mason_ensure_installed(opts)
    local registry = require 'mason-registry'
    for _, installable in ipairs(opts.ensure_installed) do
        local name, version = require('mason-core.package').Parse(installable)
        local found, pkg = pcall(registry.get_package, name)
        if not found then
            local errmsg = 'Server %q is not a valid entry in ensure_installed.'
            vim.notify(errmsg:format(name), vim.log.levels.WARN)
        elseif not pkg:is_installed() then
            install(pkg, version)
        end
    end
end

---@module "lazy"
---@return LspConfig
---@param config LspConfig
local function extend(config)
    local def_root = { '.git', '.gitignore', vim.fn.getcwd() }
    local roots
    if config['override_root'] then
        roots = config.root
    else
        roots = vim.list_extend(config.root or {}, def_root)
    end
    config['root'] = nil
    local l = require 'lsp'
    local defaults = {
        on_attach = l.on_attach,
        capabilities = require('plugins.completion').get_capabilities(),
        root_markers = roots,
    }
    local updated_config = vim.tbl_deep_extend('force', defaults, config)
    return updated_config
end

---@type LazySpec[]
return {
    extend = extend,
    ---@param server string
    ---@param config LspConfig?
    configure = function(server, config)
        config = config or {}
        vim.lsp.config(server, extend(config))
        vim.lsp.enable(server)
    end,
    {
        dir = vim.env.HOME .. '/projects/chaitanyabsprip/fastaction.nvim',
        ---@module "fastaction"
        ---@type FastActionConfig
        opts = {
            brackets = { '', '' },
            popup = { title = false },
            dismiss_keys = { '<Esc>', '<C-c>', 'j', 'k', 'q' },
            register_ui_select = true,
            priority = {
                default = {
                    { order = 1, pattern = 'organize', key = 'o' },
                    { order = 1, pattern = 'import', key = 'i' },
                    { order = 1, pattern = 'fix all', key = 'f' },
                },
                dart = {
                    { order = 1, pattern = 'relative imports everywhere', key = 'l' },
                    { order = 2, pattern = 'sort member', key = 's' },
                    { order = 2, pattern = 'wrap with widget', key = 'w' },
                    { order = 3, pattern = 'extract widget', key = 'x' },
                    { order = 4, pattern = 'column', key = 'c' },
                    { order = 4, pattern = 'extract method', key = 'e' },
                    { order = 4, pattern = 'padding', key = 'p' },
                    { order = 4, pattern = 'remove', key = 'r' },
                    { order = 4, pattern = 'wrap with padding', key = 'p' },
                    { order = 5, pattern = 'add', key = 'a' },
                    { order = 5, pattern = 'extract local', key = 'v' },
                },
            },
        },
        event = 'VeryLazy',
    },
    {
        'nvimtools/none-ls.nvim',
        dependencies = { 'jay-babu/mason-null-ls.nvim' },
        config = function(_, opts)
            local get_capabilities = require('plugins.completion').get_capabilities
            local builtins = require('null-ls').builtins
            ---@type NullSource[]
            local sources = {}
            ---@type NullSource[]
            local optSources = opts.sources
            for _, source_fn in pairs(optSources) do
                vim.list_extend(sources, source_fn(builtins))
            end
            local config = {
                on_attach = require('lsp').on_attach,
                capabilities = get_capabilities(),
                sources = sources,
            }
            require('null-ls').setup(config)
        end,
    },
    {
        'neovim/nvim-lspconfig',
        event = { 'User BufReadPreNotOil', 'BufNewFile' },
        dependencies = {
            {
                'folke/lazydev.nvim',
                -- optional = true,
                ft = { 'lua' },
                opts = {
                    library = {
                        { path = vim.env.HOME .. '/projects/chaitanyabsprip/fastaction.nvim' },
                        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
                        { path = 'LazyVim', words = { 'LazyVim' } },
                        { path = 'snacks.nvim', words = { 'Snacks' } },
                        { path = 'lazy.nvim', words = { 'LazyVim' } },
                    },
                },
            },
            {
                'williamboman/mason.nvim',
                opts = { PATH = 'skip' },
                config = function(_, opts)
                    require('mason').setup(opts)
                    mason_ensure_installed(opts)
                end,
            },
        },
        config = function(_, opts)
            local lspconfig = require 'lspconfig'
            ---@diagnostic disable-next-line: no-unknown
            for _, server in pairs(opts.servers) do
                server(lspconfig)
            end
        end,
    },
}

local plugin = {}

function plugin.bootstrap_packer()
    ---@type string
    local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
    if not vim.uv.fs_stat(lazypath) then
        vim.fn.system {
            'git',
            'clone',
            '--filter=blob:none',
            'https://github.com/folke/lazy.nvim.git',
            lazypath,
        }
        vim.fn.system { 'git', '-C', lazypath, 'checkout', 'tags/stable' } -- last stable release
    end
    vim.opt.runtimepath:prepend(lazypath)
end

plugin.setup = function()
    plugin.bootstrap_packer()
    local disabled_builtins = {
        '2html_plugin',
        'getscript',
        'getscriptPlugin',
        'gzip',
        'logiPat',
        'man',
        'matchit',
        'matchparen',
        'netrw',
        'netrwFileHandlers',
        'netrwPlugin',
        'netrwSettings',
        'rrhelper',
        'shada_plugin',
        'tar',
        'tarPlugin',
        'tohtml',
        'tutor',
        'vimball',
        'vimballPlugin',
        'zip',
        'zipPlugin',
    }
    local config = require 'config.theme'
    require('lazy').setup({
        { import = 'plugins' },
        { import = 'plugins.ui.themes.' .. config.theme },
        { import = 'plugins.explorer' },
    }, {
        -- `:lua vim.g.disabled_plugins = { 'oil.nvim' }` in a session-local
        -- init, or before lazy loads, to try life without one
        defaults = {
            lazy = true,
            cond = function(spec)
                return not vim.list_contains(vim.g.disabled_plugins or {}, spec.name)
            end,
        },
        performance = { rtp = { disabled_plugins = disabled_builtins } },
        install = { colorscheme = { 'habamax' } },
        checker = { enabled = true, notify = false },
        readme = { files = { 'README.md', 'readme.md', 'README.rst', 'readme.rst' } },
    })
end

---@param list any[]
local function dedupe_list(list)
    ---@type table<any, boolean>
    local seen = {}
    local deduped = {}
    for _, item in ipairs(list) do
        if not seen[item] then
            seen[item] = true
            table.insert(deduped, item)
        end
    end
    return deduped
end

---@param opts table<string, any>
---@param key string
---@param ... any
function plugin.extend_opts_list(opts, key, ...)
    opts[key] = opts[key] or {}
    vim.list_extend(opts[key], { ... })
    opts[key] = dedupe_list(opts[key])
    return opts[key]
end

return plugin

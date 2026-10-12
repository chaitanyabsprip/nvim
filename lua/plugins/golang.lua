local extend = require('plugins.lsp').extend

---@type LazyPluginSpec[]
return {
    {
        'ray-x/go.nvim',
        dependencies = {
            'ray-x/guihua.lua',
            'neovim/nvim-lspconfig',
            'nvim-treesitter/nvim-treesitter',
        },
        -- event = { 'CmdlineEnter' },
        cmd = {
            'Go',
            'GoModInit',
            'GoModTidy',
            'GoNew',
            'GoFmt',
            'GoBuild',
            'GoAlt',
            'GoBreakToggle',
            'GoImpl',
            'GoRun',
            'GoInstall',
            'GoTest',
            'GoTestFunc',
            'GoTestCompile',
            'GoCoverage',
            'GoCoverageToggle',
            'GoCoverag',
            'GoGet',
            'GoModifyTags',
        },
        ft = { 'go', 'gomod', 'gosum', 'gotmpl', 'gohtmltmpl', 'gotexttmpl' },
        build = ':lua require("go.install").update_all_sync()',
        keys = {
            {
                '<leader>gfi',
                '<cmd>GoIfErr<cr>',
                desc = 'Go: Autofill If-err block',
            },
            {
                '<leader>gfs',
                '<cmd>GoFillStruct<cr>',
                desc = 'Go: Autofill Struct with fields',
            },
            {
                '<leader>gfw',
                '<cmd>GoFillSwitch<cr>',
                desc = 'Go: Autofill Switch with cases',
            },
            {
                '<leader>gfp',
                'GoFixPlurals',
                desc = 'Go: Auto collate plural params with same type',
            },
        },
        config = function()
            local capabilities = require 'lsp.capabilities'
            local cb = capabilities.formatting.callback
            capabilities.formatting.callback = function(client, bufnr)
                if client.name ~= 'gopls' then return cb(client, bufnr) end
                vim.api.nvim_create_autocmd('BufWritePre', {
                    group = vim.api.nvim_create_augroup('auto_format', { clear = true }),
                    buffer = bufnr,
                    callback = function()
                        require('go.format').gofmt()
                        require('go.format').goimports()
                        vim.lsp.buf.code_action {
                            filter = function(action) return action.title == 'Organize Imports' end,
                            apply = true,
                        }
                    end,
                })
            end
            local config = extend {
                cmd = { 'gopls', '-remote=auto' },
                root = { 'go.mod', 'go.work' },
                settings = {
                    gopls = {
                        gofumpt = true,
                        analyses = {
                            unusedparams = true,
                            nilness = true,
                            unusedwrite = true,
                            useany = true,
                            unusedvariable = true,
                        },
                        completeUnimported = true,
                        staticcheck = true,
                        usePlaceholders = true,
                    },
                },
            }
            require('go').setup {
                dap_debug_keymap = false,
                dap_debug_ui = false,
                dap_debug_vt = false,
                gofmt = 'golines',
                goimports = 'gofumpt',
                lsp_gofumpt = true,
                max_line_len = 72,
                lsp_keymaps = false,
                lsp_inlay_hints = { enable = false },
                lsp_cfg = config,
                lsp_on_attach = config.on_attach,
                luasnip = true,
            }
            -- local nullls = require 'null-ls'
            -- nullls.register(require('go.null_ls').gotest())
            -- nullls.register(require('go.null_ls').gotest_action())
            -- nullls.register(require('go.null_ls').golangci_lint())
        end,
    },
    {
        'nvimtools/none-ls.nvim',
        ft = function(_, filetypes) return vim.list_extend(filetypes, { 'go' }) end,
        optional = true,
        opts = function(_, opts)
            require('config.lazy').extend_opts_list(
                opts,
                'sources',
                ---@param builtins NullBuiltin
                function(builtins) return { builtins.diagnostics.revive } end
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
                'revive',
                'gopls',
                'delve'
            )
        end,
    },
    {
        'nvim-neotest/neotest',
        optional = true,
        dependencies = {
            'nvim-neotest/neotest-go',
        },
        opts = { adapters = { ['neotest-go'] = { recursive_run = true } } },
    },
    {
        'nvim-treesitter/nvim-treesitter',
        optional = true,
        opts = function(_, opts)
            require('config.lazy').extend_opts_list(
                opts,
                'ensure_installed',
                'go',
                'gomod',
                'gowork',
                'gotmpl'
            )
        end,
    },
    {
        'leoluz/nvim-dap-go',
        dependencies = { 'mfussenegger/nvim-dap' },
        ft = 'go',
        config = function() require('dap-go').setup() end,
    },
}

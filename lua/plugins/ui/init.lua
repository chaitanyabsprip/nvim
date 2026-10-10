---@module "lazy"
---@type LazySpec[]
return {
    {
        'luukvbaal/statuscol.nvim',
        event = 'VeryLazy',
        enabled = false,
        config = function()
            local builtin = require 'statuscol.builtin'
            require('statuscol').setup {
                relculright = true,
                segments = {
                    {
                        sign = { name = { '.*' }, text = { '.*' } },
                        click = 'v:lua.ScSa',
                        maxwidth = 2,
                        auto = true,
                    },
                    {
                        sign = {
                            namespace = { 'diagnostic' },
                            maxwidth = 1,
                            colwidth = 1,
                            auto = true,
                        },
                        click = 'v:lua.ScSa',
                        auto = true,
                    },
                    {
                        text = { builtin.lnumfunc, ' ' },
                        condition = { true, builtin.not_empty },
                        click = 'v:lua.ScLa',
                    },
                    {
                        text = {
                            function(args)
                                args.fold.close = ''
                                args.fold.open = ''
                                args.fold.sep = ' '
                                return builtin.foldfunc(args)
                            end,
                            ' ',
                        },
                        click = 'v:lua.ScFa',
                        auto = true,
                    },
                    {
                        sign = { namespace = { 'gitsigns' }, colwidth = 1, wrap = true },
                        click = 'v:lua.ScSa',
                    },
                },
                -- segments = {
                --     { text = { builtin.foldfunc }, click = 'v:lua.ScFa' },
                --     { text = { '%s' }, click = 'v:lua.ScSa' },
                --     { text = { builtin.lnumfunc, ' ' }, click = 'v:lua.ScLa' },
                -- },
                -- segments = {
                --
                --   { text = { builtin.foldfunc }, click = "v:lua.ScFa" },
                --   { text = { builtin.lnumfunc }, click = "v:lua.ScLa", },
                --   {
                --     sign = { name = { ".*" }, maxwidth = 2, colwidth = 1, auto = true, wrap = true },
                --     click = "v:lua.ScSa"
                --   },
                -- }
            }
        end,
    },
    {
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
        branch = 'main',
        lazy = false,
        event = 'BufReadPre',
        opts = function(_, opts)
            opts.ensure_installed = opts.ensure_installed or {}
            vim.list_extend(opts.ensure_installed, { 'regex', 'vim', 'make' })

            local augroup = function(group) vim.api.nvim_create_augroup(group, { clear = true }) end
            local autocmd = function(event, opts)
                if not opts.disable then vim.api.nvim_create_autocmd(event, opts) end
            end
            autocmd('FileType', {
                group = augroup 'treesitter',
                pattern = opts.ensure_installed,
                callback = function()
                    vim.treesitter.start()
                    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                    -- vim.wo[0][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
                    -- vim.wo[0][0].foldmethod = 'expr'
                end,
            })

            require('nvim-treesitter').install(opts.ensure_installed)
            return {}
        end,
    },
    {
        'nvim-treesitter/nvim-treesitter-textobjects',
        event = 'BufReadPre',
        branch = 'main',
        dependencies = {
            {
                'nvim-treesitter/nvim-treesitter',
                opts = {
                    textobjects = {
                        move = {
                            enable = true,
                            set_jumps = true,
                            goto_next_start = {
                                [']p'] = {
                                    query = '@parameter.inner',
                                    desc = 'Jump to start of next parameter',
                                },
                                [']f'] = {
                                    query = '@function.outer',
                                    desc = 'Jump to start of next function',
                                },
                                [']]'] = {
                                    query = '@class.outer',
                                    desc = 'Jump to start of next class',
                                },
                            },
                            goto_next_end = {
                                [']F'] = {
                                    query = '@function.outer',
                                    desc = 'Jump to end of next function',
                                },
                                [']['] = {
                                    query = '@class.outer',
                                    desc = 'Jump to end of next class',
                                },
                            },
                            goto_previous_start = {
                                ['[p'] = {
                                    query = '@parameter.inner',
                                    desc = 'Jump to start of previous parameter',
                                },
                                ['[f'] = {
                                    query = '@function.outer',
                                    desc = 'Jump to start of previous function',
                                },
                                ['[['] = {
                                    query = '@class.outer',
                                    desc = 'Jump to start of previous class',
                                },
                            },
                            goto_previous_end = {
                                ['[F'] = {
                                    query = '@function.outer',
                                    desc = 'Jump to end of previous function',
                                },
                                ['[]'] = {
                                    query = '@class.outer',
                                    desc = 'Jump to end of previous class',
                                },
                            },
                        },
                        select = {
                            enable = true,
                            lookahead = true,
                            keymaps = {
                                ['af'] = {
                                    query = '@function.outer',
                                    desc = 'Select outer part of a function',
                                },
                                ['if'] = {
                                    query = '@function.inner',
                                    desc = 'Select inner part of a function',
                                },
                                ['ac'] = {
                                    query = '@conditional.outer',
                                    desc = 'Select outer part of a conditional',
                                },
                                ['ic'] = {
                                    query = '@conditional.inner',
                                    desc = 'Select inner part of a conditional',
                                },

                                ['aa'] = {
                                    query = '@parameter.outer',
                                    desc = 'Select outer part of a parameter',
                                },
                                ['ia'] = {
                                    query = '@parameter.inner',
                                    desc = 'Select inner part of a parameter',
                                },

                                ['av'] = {
                                    query = '@variable.outer',
                                    desc = 'Select outer part of a variable',
                                },
                                ['iv'] = {
                                    query = '@variable.inner',
                                    desc = 'Select inner part of a variable',
                                },
                            },
                        },
                        lsp_interop = {
                            enable = true,
                            border = 'rounded',
                            floating_preview_opts = {},
                            peek_definition_code = {
                                ['<leader>gd'] = '@function.outer',
                                ['<leader>gD'] = '@class.outer',
                            },
                        },
                    },
                },
            },
        },
    },
    {
        'nvim-treesitter/nvim-treesitter-context',
        event = 'BufWinEnter',
        opts = {
            enable = true,
            max_lines = 3,
            trim_scope = 'outer',
            min_window_height = 18,
            mode = 'cursor',
            line_numbers = true,
        },
    },
}

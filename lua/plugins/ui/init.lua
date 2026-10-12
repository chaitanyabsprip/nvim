---@module "lazy"
---@type LazySpec[]
return {
    {
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
        branch = 'main',
        lazy = false,
        event = 'BufReadPre',
        opts = function(_, opts)
            opts.ensure_installed = opts.ensure_installed or {}
            vim.list_extend(opts.ensure_installed, { 'regex', 'vim', 'make' })

            vim.api.nvim_create_autocmd('FileType', {
                group = vim.api.nvim_create_augroup('treesitter', { clear = true }),
                pattern = opts.ensure_installed,
                callback = function()
                    vim.treesitter.start()
                    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
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

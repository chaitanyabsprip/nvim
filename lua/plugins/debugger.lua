local debugger = {}

debugger.dap = {
    ---@type LazyPluginSpec
    spec = {
        'mfussenegger/nvim-dap',
        config = function(_, opts)
            local icons = { bookmark = '', bug = '' } --   '󰠭'
            local dap = require 'dap'
            local sign = vim.fn.sign_define
            sign(
                'DapBreakpointCondition',
                { text = '●', texthl = 'DapBreakpointCondition', linehl = '', numhl = '' }
            )
            sign('DapLogPoint', { text = '◆', texthl = 'DapLogPoint', linehl = '', numhl = '' })
            sign(
                'DapBreakpoint',
                { texthl = 'DapBreakpoint', text = icons.bug, linehl = '', numhl = 'DapBreakpoint' }
            )
            sign(
                'DapStopped',
                { texthl = 'DapStopped', text = icons.bookmark, linehl = '', numhl = 'DapStopped' }
            )

            ---@diagnostic disable-next-line: no-unknown
            for name, adapter in pairs(opts.adapters or {}) do
                dap.adapters[name] = adapter
            end
            ---@diagnostic disable-next-line: no-unknown
            for name, configuration in pairs(opts.configurations or {}) do
                dap.configurations[name] = configuration
            end

            local ui_ok, dapui = pcall(require, 'dapui')
            if not ui_ok then return end
            dap.listeners.before.event_exited['dapui_config'] = function()
                dapui.close()
                vim.keymap.del('n', '<leader>K')
            end
            dap.listeners.before.event_terminated['dapui_config'] = function() dapui.close() end
            dap.listeners.after.event_initialized['dapui_config'] = function()
                dapui.open()
                vim.keymap.set('n', '<leader>K', require('dap.ui.widgets').hover, {
                    buf = 0,
                    desc = 'dap: Show variable value',
                    silent = true,
                })
            end
        end,
        keys = {
            {
                '<leader>b',
                function() require('dap').toggle_breakpoint() end,
                silent = true,
                desc = 'Toggle debug breakpoint',
            },
            {
                '<leader>c',
                function() require('dap').continue() end,
                silent = true,
                desc = 'Continue or start debugging',
            },
            {
                '<leader>so',
                function() require('dap').step_over() end,
                silent = true,
                desc = 'dap: step over',
            },
            {
                '<leader>si',
                function() require('dap').step_into() end,
                silent = true,
                desc = 'dap: step into',
            },
            {
                '<leader>sO',
                function() require('dap').step_out() end,
                silent = true,
                desc = 'dap: step out',
            },
        },
    },
}

debugger.ui = {
    ---@type LazyPluginSpec
    spec = {
        'rcarriga/nvim-dap-ui',
        keys = {
            { '<leader>du', function() require('dapui').toggle() end, desc = 'Toggle debugger UI' },
        },
        dependencies = { 'mfussenegger/nvim-dap', 'm00qek/baleia.nvim', 'nvim-neotest/nvim-nio' },
        config = function()
            -- require 'dap'
            vim.api.nvim_create_autocmd({ 'BufWinEnter' }, {
                group = vim.api.nvim_create_augroup('ansi', { clear = true }),
                pattern = { 'DAP *', '[dap-repl*' },
                callback = function()
                    vim.cmd.setlocal 'statuscolumn='
                    vim.cmd.setlocal 'nocursorline'
                    if vim.bo.filetype == 'dap-repl' then
                        require('baleia').setup({}).automatically(vim.api.nvim_get_current_buf())
                    end
                end,
            })
            require('dapui').setup {
                controls = {
                    element = 'repl',
                    enabled = true,
                    icons = {
                        disconnect = '',
                        pause = '',
                        play = '',
                        run_last = '',
                        step_back = '',
                        step_into = '',
                        step_out = '',
                        step_over = '',
                        terminate = '',
                    },
                },
                element_mappings = {},
                expand_lines = true,
                floating = { border = 'single', mappings = { close = { 'q', '<Esc>' } } },
                force_buffers = true,
                icons = { collapsed = '', current_frame = '', expanded = '' },
                layouts = {
                    {
                        elements = {
                            { id = 'scopes', size = 0.25 },
                            { id = 'breakpoints', size = 0.25 },
                            { id = 'watches', size = 0.25 },
                            { id = 'stacks', size = 0.25 },
                        },
                        position = 'right',
                        size = 40,
                    },
                    { elements = { { id = 'repl', size = 1 } }, size = 16, position = 'bottom' },
                },
                mappings = {
                    edit = 'e',
                    expand = { '<CR>', '<2-LeftMouse>', 'l' },
                    open = 'o',
                    remove = 'd',
                    repl = 'r',
                    toggle = 't',
                },
                render = { indent = 1, max_value_lines = 100 },
            }
        end,
    },
}

debugger.spec = {
    debugger.dap.spec,
    debugger.ui.spec,
}

return debugger.spec

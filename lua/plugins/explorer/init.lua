---@type LazyPluginSpec[]
return {
    {
        'kevinhwang91/nvim-bqf',
        ft = 'qf',
        dependencies = { 'yorickpeterse/nvim-pqf', { 'junegunn/fzf', build = './install --bin' } },
        opts = {
            auto_resize_height = true,
            func_map = { open = 'o', openc = '<cr>' },
        },
    },
    {
        'yorickpeterse/nvim-pqf',
        event = 'Filetype qf',
        opts = {},
    },
    {
        'ThePrimeagen/harpoon',
        branch = 'harpoon2',
        dependencies = { 'nvim-lua/plenary.nvim' },
        keys = {
            {
                '<c-b>',
                function() require('harpoon'):list():add() end,
                desc = 'Add file to harpoon',
            },
            {
                '<c-f>',
                function()
                    local harpoon = require 'harpoon'
                    harpoon.ui:toggle_quick_menu(harpoon:list())
                end,
                desc = 'Toggle harpoon marks list',
            },
            {
                '<leader>1',
                function() require('harpoon'):list():select(1) end,
                desc = 'Jump to file 1 in harpoon',
            },
            {
                '<leader>2',
                function() require('harpoon'):list():select(2) end,
                desc = 'Jump to file 2 in harpoon',
            },
            {
                '<leader>3',
                function() require('harpoon'):list():select(3) end,
                desc = 'Jump to file 3 in harpoon',
            },
            {
                '<leader>4',
                function() require('harpoon'):list():select(4) end,
                desc = 'Jump to file 4 in harpoon',
            },
        },
        config = function()
            local harpoon = require 'harpoon'
            harpoon:setup {
                settings = { save_on_toggle = true, sync_on_ui_close = true },
            }
            harpoon:extend {
                UI_CREATE = function(cx)
                    vim.keymap.set(
                        'n',
                        '<C-v>',
                        function() harpoon.ui:select_menu_item { vsplit = true } end,
                        { buf = cx.bufnr }
                    )

                    vim.keymap.set(
                        'n',
                        '<C-x>',
                        function() harpoon.ui:select_menu_item { split = true } end,
                        { buf = cx.bufnr }
                    )

                    vim.keymap.set(
                        'n',
                        '<C-t>',
                        function() harpoon.ui:select_menu_item { tabedit = true } end,
                        { buf = cx.bufnr }
                    )
                end,
            }
        end,
    },
    {
        'stevearc/oil.nvim',
        lazy = (function()
            if vim.fn.argc() < 1 or vim.fn.argc() > 1 then return end
            ---@type string
            local path = require('utils').getargs()[1]
            local directory = vim.fn.isdirectory(path) == 1
            return not directory
        end)(),
        cmd = { 'Oil', 'Explorer' },
        opts = function()
            vim.api.nvim_create_user_command('Explorer', function()
                if vim.bo.filetype == 'oil' then
                    require('oil').close()
                else
                    return require('oil').open()
                end
            end, { nargs = 0 })
            return {
                default_file_explorer = true,
                columns = { 'icon', 'permissions' }, -- See :help oil-columns
                buf_options = { buflisted = false, bufhidden = 'hide' },
                win_options = {
                    wrap = false,
                    signcolumn = 'no',
                    cursorcolumn = false,
                    foldcolumn = '0',
                    spell = false,
                    list = false,
                    conceallevel = 3,
                    concealcursor = 'nvic',
                },
                delete_to_trash = false,
                skip_confirm_for_simple_edits = true, -- Skip the confirmation popup for simple operations
                -- Selecting a new/moved/renamed file or directory will prompt you to save changes first
                prompt_save_on_select_new_entry = true,
                constrain_cursor = 'editable',
                watch_for_changes = true,
                use_default_keymaps = false, -- Set to false to disable all of the above keymaps
                view_options = {
                    show_hidden = true, -- Show files and directories that start with "."
                    is_hidden_file = function(name, _) return vim.startswith(name, '.') end,
                    is_always_hidden = function(_, _) return false end,
                    sort = { { 'type', 'asc' }, { 'name', 'asc' } }, -- see :help oil-columns to see sortable cols
                    natural_order = false,
                },
                keymaps = { -- See :help oil-actions for a list of all available actions
                    ['g?'] = 'actions.show_help',
                    ['<CR>'] = 'actions.select',
                    ['L'] = 'actions.select',
                    ['s'] = 'actions.select_split',
                    ['S'] = 'actions.select_vsplit',
                    ['<C-t>'] = 'actions.select_tab',
                    ['<C-p>'] = 'actions.preview',
                    ['<C-c>'] = 'actions.close',
                    ['q'] = 'actions.close',
                    ['<leader>r'] = 'actions.refresh',
                    ['H'] = 'actions.parent',
                    ['_'] = 'actions.open_cwd',
                    ['`'] = 'actions.cd',
                    ['~'] = 'actions.tcd',
                    ['gs'] = 'actions.change_sort',
                    ['g.'] = 'actions.toggle_hidden',
                },
                float = {
                    padding = 1,
                    max_width = 50,
                    max_height = 20,
                    border = 'rounded',
                    win_options = { winblend = 0 },
                    override = function(conf)
                        local HEIGHT_RATIO = 0.9
                        local WIDTH_RATIO = 0.3
                        ---@type number
                        local screen_w = vim.opt.columns:get()
                        ---@type number
                        local screen_h = vim.opt.lines:get() - vim.opt.cmdheight:get()
                        local window_w = screen_w * WIDTH_RATIO
                        local window_h = screen_h * HEIGHT_RATIO
                        local window_w_int = math.floor(window_w)
                        local window_h_int = math.floor(window_h)
                        local center_x = (screen_w - window_w - (screen_w * 0.03))
                        ---@type number
                        local center_y = ((vim.opt.lines:get() - window_h) / 2)
                            - vim.opt.cmdheight:get()
                        conf.row = center_y
                        conf.col = center_x
                        conf.width = window_w_int
                        conf.height = window_h_int
                        return conf
                    end,
                },
                preview = {
                    max_width = { 72, 0.6 },
                    min_width = { 40, 0.4 },
                    width = nil,
                    max_height = { 30, 0.9 },
                    min_height = { 5, 0.1 },
                    height = nil,
                    border = 'rounded',
                    win_options = { winblend = 0 },
                },
                progress = {
                    max_width = 0.9,
                    min_width = { 40, 0.4 },
                    width = nil,
                    max_height = { 10, 0.9 },
                    min_height = { 5, 0.1 },
                    height = nil,
                    border = 'rounded',
                    minimized_border = 'none',
                    win_options = { winblend = 0 },
                },
            }
        end,
        dependencies = { 'nvim-tree/nvim-web-devicons' },
    },
}

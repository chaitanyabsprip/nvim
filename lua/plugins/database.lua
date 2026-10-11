---@type LazySpec[]
return {
    {
        'kristijanhusak/vim-dadbod-completion',
        dependencies = { 'hrsh7th/nvim-cmp' },
        ft = { 'sql', 'mysql', 'plsql' },
        config = function()
            require('cmp').setup.filetype({ 'sql' }, {
                sources = {
                    { name = 'vim-dadbod-completion' },
                    { name = 'buffer' },
                },
            })
        end,
    },
    {
        'kristijanhusak/vim-dadbod-ui',
        dependencies = { 'tpope/vim-dadbod', 'kristijanhusak/vim-dadbod-completion' },
        init = function()
            vim.g.db_ui_use_nerd_fonts = true
            vim.g.db_ui_show_database_icon = true
            vim.g.db_ui_use_nvim_notify = true
            vim.g.db_ui_execute_on_save = false
            vim.g.db_ui_disable_mappings_dbui = true
            vim.api.nvim_create_autocmd('FileType', {
                pattern = 'dbui',
                callback = function(args)
                    ---@type integer
                    local buffer = args.buf
                    local opts = { buffer = buffer, noremap = true, silent = true }
                    for _, val in ipairs { 'o', '<cr>', '<2-LeftMouse>' } do
                        vim.keymap.set('n', val, '<Plug>(DBUI_SelectLine)', opts)
                    end
                    vim.keymap.set('n', '<c-v>', '<Plug>(DBUI_SelectLineVsplit)', opts)
                    vim.keymap.set('n', 'R', '<Plug>(DBUI_Redraw)', opts)
                    vim.keymap.set('n', 'd', '<Plug>(DBUI_DeleteLine)', opts)
                    vim.keymap.set('n', 'A', '<Plug>(DBUI_AddConnection)', opts)
                    vim.keymap.set('n', 'I', '<Plug>(DBUI_ToggleDetails)', opts)
                    vim.keymap.set('n', 'r', '<Plug>(DBUI_RenameLine)', opts)
                    vim.keymap.set('n', 'q', '<Plug>(DBUI_Quit)', opts)
                    -- vim.keymap.set('n', 'F', '<Plug>(DBUI_GotoFirstSibling)', opts)
                    -- vim.keymap.set('n', 'H', '<Plug>(DBUI_GotoLastSibling)', opts)
                    vim.keymap.set('n', 'H', '<Plug>(DBUI_GotoParentNode)', opts)
                    vim.keymap.set('n', 'L', '<Plug>(DBUI_GotoChildNode)', opts)
                    vim.keymap.set('n', 'K', '<Plug>(DBUI_GotoPrevSibling)', opts)
                    vim.keymap.set('n', 'J', '<Plug>(DBUI_GotoNextSibling', opts)
                end,
            })
            vim.g.db_ui_disable_mappings_sql = true
            vim.api.nvim_create_autocmd('FileType', {
                pattern = 'sql',
                callback = function(args)
                    ---@type integer
                    local buffer = args.buf
                    local opts = { buffer = buffer, noremap = true, silent = true }
                    vim.keymap.set('n', '<leader>W', '<Plug>(DBUI_SaveQuery)', opts)
                    vim.keymap.set('n', '<leader>E', '<Plug>(DBUI_EditBindParameters)', opts)
                    vim.keymap.set('n', 'S', '<Plug>(DBUI_ExecuteQuery)', opts)
                    vim.keymap.set('v', 'S', '<Plug>(DBUI_ExecuteQuery)', opts)
                end,
            })
        end,
        cmd = { 'DBUI', 'DBUIToggle', 'DBUIAddConnection', 'DBUIFindBuffer' },
        keys = {
            {
                '<leader>dt',
                '<cmd>DBUIToggle<cr>',
                noremap = true,
                silent = true,
                desc = 'DB: Toggle database ui',
            },
        },
    },
    {
        'tpope/vim-dadbod',
        dependencies = { 'kristijanhusak/vim-dadbod-completion' },
        cmd = 'DB',
    },
}

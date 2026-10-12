local prompt = '▍ '
local misc_opts = {
    winopts = {
        row = vim.o.lines,
        col = 0,
        width = 1,
        height = 0.5,
        preview = {
            layout = 'vertical',
            vertical = 'up:50%',
        },
    },
    prompt = prompt,
}
---@type LazyPluginSpec[]
return {
    {
        'ibhagwan/fzf-lua',
        cmd = { 'FzfLua' },
        keys = {
            {
                '<leader><space>',
                function() require('fzf-lua').files {} end,
                silent = true,
                desc = 'FzfLua: File Finder',
            },
            {
                'go',
                function() require('fzf-lua').oldfiles {} end,
                silent = true,
                desc = 'FzfLua: oldfiles',
            },
            -- {
            --     'gW',
            --     function() require('fzf-lua').grep_cword {} end,
            --     noremap = true,
            --     silent = true,
            --     desc = 'FzfLua: grep word under cursor',
            -- },
            -- {
            --     'gw',
            --     function() require('fzf-lua').grep { search = vim.fn.input { prompt = 'Grep > ' } } end,
            --     noremap = true,
            --     silent = true,
            --     desc = 'FzfLua: grep and filter',
            -- },
            -- {
            --     'gw',
            --     function() require('fzf-lua').grep_visual {} end,
            --     mode = 'v',
            --     noremap = true,
            --     silent = true,
            --     desc = 'FzfLua: grep visual selection',
            -- },
            {
                ';c',
                function() require('fzf-lua').git_status {} end,
                silent = true,
                desc = 'FzfLua: git changes',
            },
            {
                ';b',
                function() require('fzf-lua').git_branches {} end,
                silent = true,
                desc = 'FzfLua: git branches',
            },
            {
                '<leader>thi',
                function() require('fzf-lua').highlights(misc_opts) end,
                silent = true,
                desc = 'FzfLua: Highlights',
            },
            {
                '<leader>thk',
                function() require('fzf-lua').keymaps(misc_opts) end,
                silent = true,
                desc = 'FzfLua: Keymaps',
            },
            {
                '<leader>tht',
                function() require('fzf-lua').helptags(misc_opts) end,
                silent = true,
                desc = 'FzfLua: Help tags',
            },
            -- {
            --     '<leader>fn',
            --     function() require('fzf-lua').files { cwd = os.getenv 'NOTESPATH' } end,
            --     noremap = true,
            --     silent = true,
            --     desc = 'FzfLua: Find notes',
            -- },
        },
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        opts = {
            winopts = {
                border = 'rounded',
                height = 0.8,
                width = 0.9,
                preview = {
                    border = 'noborder',
                    horizontal = 'right:50%',
                },
            },
            keymap = {
                fzf = {
                    true,
                    ['ctrl-q'] = 'select-all+accept',
                },
            },
            fzf_opts = { ['--layout'] = 'default' },
            files = {
                previewer = 'bat',
                prompt = prompt,
                cwd_prompt = false,
            },
            grep = { prompt = prompt },
            oldfiles = {
                prompt = prompt,
                cwd_prompt = false,
            },
            git = {
                status = { prompt = prompt },
                branches = { prompt = prompt },
            },
        },
    },
}

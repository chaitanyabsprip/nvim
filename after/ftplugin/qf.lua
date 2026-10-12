vim.cmd 'syntax on'
vim.opt_local.number = false
vim.opt_local.relativenumber = false
vim.opt_local.buflisted = false
vim.o.statuscolumn = ''

vim.keymap.set('n', '<leader>f', function()
    vim.ui.input({ prompt = 'Filter: ', completion = 'buffer' }, function(input)
        if input == nil or input == '' then return end
        vim.cmd([[:Cfilter ]] .. input)
    end)
end, { buffer = 0, desc = 'Filter qf list' })

vim.keymap.set('n', 'dd', function()
    local qf = require 'quickfix'
    if vim.g.qf_source == 'buffers' then qf.delete_buf_from_qf() end
    qf.delete_qf_entry()
end, { buffer = 0, desc = 'Delete current entry from quickfix list' })

local source = vim.g.qf_source
local has_gitsigns, _ = pcall(require, 'gitsigns')
local target = (source == 'git-0' and 0) or (source == 'git-all' and 'all')
if target and has_gitsigns then
    vim.keymap.set(
        'n',
        's',
        '<cr><cmd>cclose<cr><cmd>Gitsigns stage_hunk<cr><cmd>sleep 100m<cr><cmd>Gitsigns setqflist '
            .. target
            .. '<cr>',
        { buffer = vim.api.nvim_get_current_buf(), desc = 'Git: Stage hunk from qf' }
    )
end

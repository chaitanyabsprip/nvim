local M = {}
---@type integer?
local timer

function M.turn_off_highlight_after_expiration(timeout)
    if timer then vim.fn.timer_stop(timer) end
    timer = vim.fn.timer_start(timeout or M.timeout, function() vim.cmd.nohlsearch() end)
end

function M.setup(opts)
    opts = opts or {}
    M.timeout = opts.timeout or 500
    -- ensure n and N highlight for only a brief time
    local lua_command_string =
        ":lua require('search_highlight').turn_off_highlight_after_expiration()<CR>"

    vim.api.nvim_set_keymap(
        'n',
        'n',
        'n' .. lua_command_string .. 'zzzv',
        { noremap = true, silent = true }
    )
    vim.api.nvim_set_keymap(
        'n',
        'N',
        'N' .. lua_command_string .. 'zzzv',
        { noremap = true, silent = true }
    )
    vim.opt.hlsearch = true

    -- ensure the initial lookup using / or ? highlight for only a brief time
    vim.api.nvim_create_autocmd('CmdlineLeave', {
        callback = function()
            local cmd_type = vim.fn.expand '<afile>'
            vim.schedule(function()
                if cmd_type ~= nil and (cmd_type == '/' or cmd_type == '?') then
                    require('search_highlight').turn_off_highlight_after_expiration()
                end
            end)
        end,
    })
end

return M

local diagnostics = {}
local fn = require('f').fn

local function get_qf_diagnostics(bufnr, severity)
    vim.g.d_bufnr = bufnr
    vim.g.d_severity = severity
    local d = vim.diagnostic
    return d.toqflist(d.get(bufnr, { severity = severity }))
end

---@param qf_item QfItem
local function jump_to_location(qf_item)
    local api = vim.api
    local bufnr = qf_item.bufnr
    local win = api.nvim_get_current_win()
    api.nvim_set_option_value('buflisted', true, { buf = bufnr })
    api.nvim_win_set_buf(win, bufnr)
    api.nvim_set_current_win(win)
    api.nvim_win_set_cursor(win, { qf_item.lnum, qf_item.col })
    api.nvim_win_call(win, function() vim.cmd 'normal! zv' end) -- Open folds under the cursor
end

local function set_list(items, scope, action)
    action = action or ' '
    ---@type {title: string, items: QfItem[]}
    local what = { title = scope .. ' Diagnostics', items = items }
    if scope == 'Document' then
        vim.fn.setloclist(0, {}, action, what)
        vim.api.nvim_command 'botright lopen'
    else
        vim.fn.setqflist({}, action, what)
        vim.api.nvim_command 'botright copen'
    end
end

local function get_diagnostics(bufnr, severity)
    return function()
        local items = get_qf_diagnostics(bufnr, severity)
        local scope = bufnr and 'Document' or 'Workspace'
        local severity_name = (severity and (vim.diagnostic.severity[severity] .. ' ') or ''):lower()
        if #items == 0 then
            return vim.notify(
                'No ' .. severity_name .. 'diagnostics found in the ' .. scope,
                vim.log.levels.INFO
            )
        end
        if #items == 1 then return jump_to_location(items[1]) end
        vim.g.qf_source = 'diagnostics'
        set_list(items, scope)
    end
end

function diagnostics.on_attach(_, bufnr)
    local function map(lhs, rhs, desc)
        vim.keymap.set('n', lhs, rhs, { buf = bufnr, desc = desc, silent = true })
    end

    -- ,<upper> lists the whole workspace, ,<lower> the current document
    for _, entry in ipairs {
        { 'D' },
        { 'E', 'ERROR' },
        { 'W', 'WARN' },
        { 'I', 'INFO' },
        { 'H', 'HINT' },
    } do
        local key, name = entry[1], entry[2]
        local severity = name and vim.diagnostic.severity[name]
        local what = name and name:lower() or 'all'
        map(
            ',' .. key,
            get_diagnostics(nil, severity),
            ('Enlist %s workspace diagnostics in quickfix'):format(what)
        )
        map(
            ',' .. key:lower(),
            get_diagnostics(bufnr, severity),
            ('Enlist %s document diagnostics in quickfix'):format(what)
        )
    end

    map(',l', vim.diagnostic.open_float, 'Show current line diagnostics in a floating window')
    local function on_jump(_, buf) vim.diagnostic.open_float { bufnr = buf } end
    map(
        ',n',
        fn(vim.diagnostic.jump, { count = 1, on_jump = on_jump }),
        'Go to the next diagnostic'
    )
    map(
        ',p',
        fn(vim.diagnostic.jump, { count = -1, on_jump = on_jump }),
        'Go to the previous diagnostic'
    )

    local group = vim.api.nvim_create_augroup('update_diagnostics', { clear = true })
    vim.api.nvim_create_autocmd('DiagnosticChanged', {
        group = group,
        callback = require('utils').debounce(300, function()
            if vim.g.qf_source ~= 'diagnostics' then return end
            local qf_items = get_qf_diagnostics(vim.g.d_bufnr, vim.g.d_severity)
            vim.fn.setqflist({}, 'r', { title = 'Diagnostics', items = qf_items })
        end),
    })
    vim.api.nvim_create_autocmd('WinLeave', {
        group = group,
        callback = function()
            if vim.bo.buftype == 'quickfix' then vim.g.qf_source = nil end
        end,
    })
end

return diagnostics

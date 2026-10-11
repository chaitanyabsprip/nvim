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
    local workspace_errors = get_diagnostics(nil, vim.diagnostic.severity.ERROR)
    local workspace_warnings = get_diagnostics(nil, vim.diagnostic.severity.WARN)
    local workspace_infos = get_diagnostics(nil, vim.diagnostic.severity.INFO)
    local workspace_hints = get_diagnostics(nil, vim.diagnostic.severity.HINT)
    local document_errors = get_diagnostics(bufnr, vim.diagnostic.severity.ERROR)
    local document_warnings = get_diagnostics(bufnr, vim.diagnostic.severity.WARN)
    local document_infos = get_diagnostics(bufnr, vim.diagnostic.severity.INFO)
    local document_hints = get_diagnostics(bufnr, vim.diagnostic.severity.HINT)
    vim.keymap.set('n', ',D', (get_diagnostics()), {
        buffer = bufnr,
        desc = 'Enlist all workspace diagnostics in quickfix',
        noremap = true,
        silent = true,
    })
    vim.keymap.set('n', ',d', (get_diagnostics(bufnr)), {
        buffer = bufnr,
        desc = 'Enlist all document diagnostics in quickfix',
        noremap = true,
        silent = true,
    })
    vim.keymap.set('n', ',E', workspace_errors, {
        buffer = bufnr,
        desc = 'Enlist workspace error diagnostics in quickfix',
        noremap = true,
        silent = true,
    })
    vim.keymap.set('n', ',W', workspace_warnings, {
        buffer = bufnr,
        desc = 'Enlist workspace warning diagnostics in quickfix',
        noremap = true,
        silent = true,
    })
    vim.keymap.set('n', ',I', workspace_infos, {
        buffer = bufnr,
        desc = 'Enlist workspace info diagnostics in quickfix',
        noremap = true,
        silent = true,
    })
    vim.keymap.set('n', ',H', workspace_hints, {
        buffer = bufnr,
        desc = 'Enlist workspace hint diagnostics in quickfix',
        noremap = true,
        silent = true,
    })
    vim.keymap.set('n', ',e', document_errors, {
        buffer = bufnr,
        desc = 'Enlist document error diagnostics in quickfix',
        noremap = true,
        silent = true,
    })
    vim.keymap.set('n', ',w', document_warnings, {
        buffer = bufnr,
        desc = 'Enlist document warning diagnostics in quickfix',
        noremap = true,
        silent = true,
    })
    vim.keymap.set('n', ',i', document_infos, {
        buffer = bufnr,
        desc = 'Enlist document info diagnostics in quickfix',
        noremap = true,
        silent = true,
    })
    vim.keymap.set('n', ',h', document_hints, {
        buffer = bufnr,
        desc = 'Enlist document hint diagnostics in quickfix',
        noremap = true,
        silent = true,
    })
    vim.keymap.set('n', ',l', vim.diagnostic.open_float, {
        buffer = bufnr,
        desc = 'Show current line diagnostics in a floating window',
        noremap = true,
        silent = true,
    })
    local function on_jump(_, buf) vim.diagnostic.open_float { bufnr = buf } end
    vim.keymap.set('n', ',n', fn(vim.diagnostic.jump, { count = 1, on_jump = on_jump }), {
        buffer = bufnr,
        desc = 'Go to the next diagnostic',
        noremap = true,
        silent = true,
    })
    vim.keymap.set('n', ',p', fn(vim.diagnostic.jump, { count = -1, on_jump = on_jump }), {
        buffer = bufnr,
        desc = 'Go to the previous diagnostic',
        noremap = true,
        silent = true,
    })

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

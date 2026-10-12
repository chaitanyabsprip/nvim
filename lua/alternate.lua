local M = {}
local a = vim.api

---@param altBufnr integer
---@return boolean
local function hasAltFile(altBufnr)
    if altBufnr < 0 then return false end
    local valid = a.nvim_buf_is_valid(altBufnr)
    local nonSpecial = a.nvim_get_option_value('buftype', { buf = altBufnr }) == ''
    local moreThanOneBuffer = #(vim.fn.getbufinfo { buflisted = 1 }) > 1
    local currentBufNotAlt = vim.api.nvim_get_current_buf() ~= altBufnr -- fixes weird rare vim bug
    local altFileExists = vim.uv.fs_stat(a.nvim_buf_get_name(altBufnr)) ~= nil

    return valid and nonSpecial and moreThanOneBuffer and currentBufNotAlt and altFileExists
end

---get the alternate oldfile, accounting for non-existing files
---@nodiscard
---@return string|nil path of oldfile, nil if none exists in all oldfiles
local function altOldfile()
    local curPath = a.nvim_buf_get_name(0)
    for _, path in ipairs(vim.v.oldfiles) do
        if vim.uv.fs_stat(path) and not path:find '/COMMIT_EDITMSG$' and path ~= curPath then
            return path
        end
    end
    return nil
end

---switch to alternate buffer/oldfile (in that priority)
function M.gotoAltBuffer()
    if vim.bo.buftype ~= '' then return end -- deactivate if in a special buffer

    local altBufNr = vim.fn.bufnr '#' ---@diagnostic disable-line: param-type-mismatch
    local altOld = altOldfile()

    if hasAltFile(altBufNr) then
        vim.cmd.buffer '#'
    elseif altOld then
        vim.cmd.edit(altOld)
    else
        vim.notify(
            'No Alt File and not Oldfile available.',
            vim.log.levels.WARN,
            { title = 'AltAlt' }
        )
    end
end

return M

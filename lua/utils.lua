local M = {}

function M.debounce(ms, fn)
    local timer = vim.uv.new_timer()
    return function(...)
        local argv = { ... }
        assert(timer ~= nil, 'time must not be nil')
        timer:start(ms, 0, function()
            timer:stop()
            vim.schedule_wrap(fn)(unpack(argv))
        end)
    end
end

local hex_to_rgb = function(hex_str)
    local hex = '[abcdef0-9][abcdef0-9]'
    local pat = '^#(' .. hex .. ')(' .. hex .. ')(' .. hex .. ')$'
    hex_str = string.lower(hex_str)

    assert(string.find(hex_str, pat) ~= nil, 'hex_to_rgb: invalid hex_str: ' .. tostring(hex_str))

    local red, green, blue = string.match(hex_str, pat)
    return { tonumber(red, 16), tonumber(green, 16), tonumber(blue, 16) }
end

function M.blend(fg, bg, alpha)
    bg = hex_to_rgb(bg)
    fg = hex_to_rgb(fg)

    local blendChannel = function(i)
        ---@type number
        local ret = (alpha * fg[i] + ((1 - alpha) * bg[i]))
        return math.floor(math.min(math.max(0, ret), 255) + 0.5)
    end

    return string.format('#%02X%02X%02X', blendChannel(1), blendChannel(2), blendChannel(3))
end

function M.darken(hex, amount, bg) return M.blend(hex, bg or M.bg, math.abs(amount)) end

function M.lighten(hex, amount, fg) return M.blend(hex, fg or M.fg, math.abs(amount)) end

function M.get_visual_selection()
    -- this will exit visual mode
    -- use 'gv' to reselect the text
    local _, csrow, cscol, cerow, cecol
    local mode = vim.fn.mode()
    if mode == 'v' or mode == 'V' or mode == '' then
        -- if we are in visual mode use the live position
        _, csrow, cscol, _ = unpack(vim.fn.getpos '.')
        _, cerow, cecol, _ = unpack(vim.fn.getpos 'v')
        if mode == 'V' then
            -- visual line doesn't provide columns
            cscol, cecol = 0, 999
        end
    else
        -- otherwise, use the last known visual position
        _, csrow, cscol, _ = unpack(vim.fn.getpos "'<")
        _, cerow, cecol, _ = unpack(vim.fn.getpos "'>")
    end
    -- swap vars if needed
    if cerow < csrow then
        csrow, cerow = cerow, csrow
    end
    if cecol < cscol then
        cscol, cecol = cecol, cscol
    end
    local lines = vim.fn.getline(csrow, cerow)
    local n = #lines
    if n <= 0 then return '' end
    lines[n] = string.sub(lines[n], 1, cecol)
    lines[1] = string.sub(lines[1], cscol)
    return table.concat(lines, '\n'),
        {
            start = { line = csrow, char = cscol },
            ['end'] = { line = cerow, char = cecol },
        }
end

function M.getargs()
    ---@diagnostic disable-next-line: no-unknown
    local argv = vim.tbl_filter(function(arg)
        local nvim = arg ~= 'nvim' and arg ~= '/usr/local/bin/nvim'
        local embed = arg ~= '--embed'
        local i = arg ~= '-i'
        local none = arg ~= 'NONE'
        return embed and i and none and nvim
    end, vim.v.argv)
    return argv
end

function M.open_explorer_on_startup()
    if vim.fn.argc() < 1 or vim.fn.argc() > 1 then return end
    ---@type string
    local path = M.getargs()[1]
    local directory = vim.fn.isdirectory(path) == 1
    if not directory then return end
    vim.cmd.cd(path)
    vim.cmd 'Explorer'
end

---@param str string
---@return string
function M.rg_escape(str)
    if not str then return str end
    -- [(~'"\/$?'`*&&||;[]<>)]
    -- escape "\~'$?*|[()^-."
    local ret = str
        :gsub("[\\~'$?*|{\\[()^%-%.%+]", function(x) return '\\' .. x end)
        -- Escape newline (#1203) at the end so we
        -- don't end up escaping the backslash twice
        :gsub(
            '\n',
            '\\n'
        )
    ret = '"' .. ret .. '"'
    return ret
end

return M

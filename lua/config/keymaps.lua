---@diagnostic disable: no-unknown
-- local function toggle_win_zoom()
--     vim.opt.winminwidth = 0
--     vim.opt.winminheight = 0
--     return function()
--         if vim.g.zoom then
--             vim.cmd [[wincmd =]]
--             vim.g.zoom = false
--         else
--             vim.cmd [[wincmd _]]
--             vim.cmd [[wincmd |]]
--             vim.g.zoom = true
--         end
--     end
-- end

local function cowboy(disabled_ft)
    ---@type table?
    local id
    local ok = true
    for _, key in ipairs { 'h', 'j', 'k', 'l', 'w', 'b' } do
        local count = 0
        local timer = assert(vim.loop.new_timer())
        local map = key
        vim.keymap.set('n', key, function()
            if table.contains(disabled_ft, vim.bo.filetype) then return map end
            if vim.v.count > 0 then count = 0 end
            if count >= 10 then
                ok, id = pcall(vim.notify, 'Stop repeating chars', vim.log.levels.WARN, {
                    icon = ' 󰺛',
                    replace = id,
                    keep = function() return count >= 10 end,
                })
                if not ok then
                    id = nil
                    return map
                end
            else
                count = count + 1
                timer:start(2000, 0, function() count = 0 end)
                return map
            end
        end, { expr = true, silent = true })
    end
end

local keymaps = {}

local api = vim.api
local keymap = vim.keymap

local function buf_kill(target_buf, should_force)
    if not should_force and vim.bo.modified then
        return api.nvim_echo({ { 'Buffer is modified. Force required.' } }, false, { err = true })
    end
    local command = 'bd'
    if should_force then command = command .. '!' end
    if target_buf == 0 or target_buf == nil then target_buf = api.nvim_get_current_buf() end
    ---@type BufInfo[]
    local buffers = vim.fn.getbufinfo { buflisted = 1 }
    if #buffers == 1 then return api.nvim_command(command) end
    ---@type integer, integer[]
    local nextbuf, windows
    for i, buf in ipairs(buffers) do
        if buf.bufnr == target_buf then
            windows = buf.windows
            nextbuf = buffers[(i - 1 + 1) % #buffers + 1].bufnr
            break
        end
    end
    if nextbuf == nil then nextbuf = api.nvim_create_buf(true, true) end
    for _, winid in ipairs(windows) do
        api.nvim_win_set_buf(winid, nextbuf)
    end
    api.nvim_command(table.concat({ command, target_buf }, ' '))
end

---@param desc string?
---@return table
local function opts(desc)
    if desc == '' then desc = nil end
    return {
        desc = desc,
        noremap = true,
        silent = true,
    }
end

keymaps.setup = function()
    -- Leader bindings
    keymap.set('n', '<Space>', '<NOP>', opts())
    vim.g.mapleader = ' '

    keymap.set('n', '<leader>q', '<cmd>q<cr>', opts 'Close window (:q)')
    keymap.set('i', '<c-c>', '<NOP>', opts 'To not be annoyed by the <c-c> messages all the time')
    keymap.set('x', '<c-c>', '<NOP>', opts 'To not be annoyed by the <c-c> messages all the time')
end

function keymaps.lazy()
    local utils = require 'utils'
    keymap.set('n', '<leader>e', '<cmd>Explorer<cr>', opts 'Toggle file explorer')
    keymap.set('n', '_', '^', opts 'Jump to the start of the line')
    keymap.set('x', '_', '^', opts 'Jump to the start of the line')
    keymap.set('n', '&', 'g_', opts 'Jump to the end of the line')
    keymap.set('x', '&', 'g_', opts 'Jump to the end of the line')
    keymap.set('v', 'J', ":m '>+1<cr>gv=gv", opts 'Move selected lines down')
    keymap.set('v', 'K', ":m '<-2<cr>gv=gv", opts 'Move selected lines up')
    keymap.set('n', ')', '<cmd>vertical resize +5<cr>', opts 'Increase current window height')
    keymap.set('n', '(', '<cmd>vertical resize -5<cr>', opts 'Decrease current window height')
    keymap.set('n', '+', '<cmd>res +1<cr>', opts 'Increase current window width')
    keymap.set('n', '-', '<cmd>res -1<cr>', opts 'Decrease current window width')
    keymap.set('v', '<', '<gv', opts 'Maintain visual selection while decreasing indent')
    keymap.set('v', '>', '>gv', opts 'Maintain visual selection while increasing indent')
    keymap.set('v', '=', '=gv', opts 'Maintain visual selection while auto fixing indent')
    keymap.set('n', '<leader>y', '<cmd>%y+<cr>', opts 'Yank whole buffer to system clipboard')
    keymap.set('n', '<leader>v', 'ggVG', opts 'Select whole buffer')
    keymap.set('v', 'p', '"_dP', opts 'Paste inplace without yanking selected text')
    keymap.set('n', '<TAB>', '<cmd>tabnext<cr>', opts 'To next tab')
    keymap.set('n', '<S-TAB>', '<cmd>tabprevious<cr>', opts 'To previous tab')
    keymap.set('n', 'n', 'nzzzv', opts 'Jump to next match and center line')
    keymap.set('n', 'N', 'Nzzzv', opts 'Jump to previous match and center line')
    keymap.set('n', 'J', 'mzJ`z', opts 'Join lines without moving cursor')
    keymap.set('n', '}', '}zz', opts 'Like text object motion } but centers line')
    keymap.set('n', '{', '{zz', opts 'Like text object motion { but centers line')
    keymap.set('n', '<c-d>', '<c-d>zz', opts 'Like text object motion <c-d> but centers line')
    keymap.set('n', '<c-u>', '<c-u>zz', opts 'Like text object motion <c-u>{ but centers line')
    keymap.set('v', '<c-d>', '<c-d>zz', opts 'Like text object motion <c-d> but centers line')
    keymap.set('v', '<c-u>', '<c-u>zz', opts 'Like text object motion <c-u>{ but centers line')
    keymap.set(
        'n',
        '<leader>r',
        ':%s/\\<<c-r><c-w>\\>/<c-r><c-w>/gI<Left><Left><Left>',
        opts 'Search and replace, in current buffer, word under cursor'
    )
    keymap.set(
        'v',
        '<leader>r',
        '"hy:%s/<C-r>h//gI<left><left><left>',
        opts 'Search and replace, in current buffer, visual selection'
    )
    keymap.set(
        'v',
        '<leader>s',
        'y:%s/<c-r>0/<c-r>0/gI<Left><Left><Left>',
        opts 'Search and modify, in current buffer, visual selection'
    )
    keymap.set('n', 'gn', '<cmd>cnext<cr>zz', opts 'Jump to next result from quickfix')
    keymap.set('n', 'gp', '<cmd>cprev<cr>zz', opts 'Jump to prev result from quickfix')
    keymap.set('n', 'gj', '<c-o>', opts 'Jump back the jump list')
    keymap.set('n', 'gk', '<c-i>', opts 'Jump forward the jump list')
    keymap.set('c', '<c-a>', '<Home>', opts 'Jump to the start of the command')
    keymap.set('c', '<c-f>', '<c-Right>', opts 'Move cursor one character right')
    keymap.set('c', '<c-b>', '<c-Left>', opts 'Move cursor one character left')
    keymap.set('c', '<c-o>', '<Up>', opts 'Move cursor one character left')
    keymap.set('c', '<c-i>', '<Down>', opts 'Move cursor one character left')
    keymap.set('n', 'gw', function()
        vim.g.qf_source = 'grep'
        vim.ui.input(
            { prompt = '▍ ' },
            function(input) vim.cmd([[silent grep! ]] .. utils.rg_escape(input)) end
        )
        vim.cmd [[copen 12]]
    end, opts 'Grep query and populate quickfix')
    keymap.set('n', 'gW', function()
        vim.g.qf_source = 'grep'
        vim.cmd([[silent grep! ]] .. utils.rg_escape(vim.fn.expand '<cword>'))
        vim.cmd [[copen 12]]
    end, opts 'Grep query and populate quickfix')
    keymap.set('v', 'gw', function()
        local selection, _ = utils.get_visual_selection()
        vim.g.qf_source = 'grep'
        vim.cmd([[silent grep! ]] .. utils.rg_escape(selection))
        vim.cmd [[copen 12]]
    end, opts())

    cowboy { 'oil', 'qf', 'help', 'noice', 'lazy', 'dbout' }
    keymap.set('n', 'X', buf_kill, opts 'Close current buffer')
    -- keymap.set('n', '<c-w>z', toggle_win_zoom(), opts 'Toggle window zoom')
    -- keymap.set('n', 'gz', toggle_win_zoom(), opts 'Toggle window zoom')

    local qf = require 'quickfix'
    keymap.set('n', 'gb', qf.buffers, opts 'Quickfix: List buffers')
    keymap.set(
        'n',
        'ge',
        '?```<cr>jV/```<cr>k!runme<cr>:noh<cr>',
        opts 'Run shell code within markdown code snipper'
    )
    keymap.set('v', 'ge', 'dO```sh<esc>o```<esc>kpkw', opts 'Wrap selection in code block')
    keymap.set('n', ',,', require('alternate').gotoAltBuffer, opts 'Switch to Alternate buffer')

    keymap.set('n', '<leader>ot', '<cmd>Leaf window<cr>', opts 'Leaf (Markdown Preview in tmux)')
    keymap.set('n', '<leader>of', '<cmd>Leaf float<cr>', opts 'Leaf (Markdown Preview in tmux popup)')

    keymap.del('n', 'grr')
    keymap.del({ 'x', 'n' }, 'gra')
    keymap.del('n', 'grn')
end

-- " " Copy to clipboard
-- vnoremap  <leader>y  "+y
-- nnoremap  <leader>Y  "+yg_
-- nnoremap  <leader>y  "+y
-- nnoremap  <leader>yy  "+yy
--
-- " " Paste from clipboard
-- nnoremap <leader>p "+p
-- nnoremap <leader>P "+P
-- vnoremap <leader>p "+p
-- vnoremap <leader>P "+P

return keymaps

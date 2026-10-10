---@diagnostic disable: no-unknown
---@module "lazy"
---@type table<string, LazySpec>
local editing = {}

editing.bigfiles = {
    'LunarVim/bigfile.nvim',
    event = 'BufReadPre',
    opts = {},
}

editing.eyeliner = {
    'jinh0/eyeliner.nvim',
    event = 'BufWinEnter',
    opts = {
        highlight_on_key = true,
        dim = true,
        disabled_filetypes = { 'fastaction_popup' },
        disabled_buftypes = { 'nofile', 'prompt' },
    },
}

editing.surround = {
    'kylechui/nvim-surround',
    version = '*',
    event = 'BufWinEnter',
    opts = {},
}

editing.spec = {
    editing.eyeliner,
    editing.surround,
}

return editing.spec

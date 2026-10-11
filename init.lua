local config = require 'config'
config.disable_builtins()
vim.g.mapleader = ' '
require('config.lazy').setup()
config.setup()
local keymaps = require 'config.keymaps'
keymaps.setup()
vim.api.nvim_create_autocmd('User', {
    group = vim.api.nvim_create_augroup('init', { clear = true }),
    pattern = 'VeryLazy',
    callback = function()
        config.lazy()
        keymaps.lazy()
    end,
})
-- vim.lsp.log.set_level 'debug'

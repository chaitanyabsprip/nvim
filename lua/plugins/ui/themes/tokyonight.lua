local config = require 'config.theme'
local name = 'tokyonight'

---@type LazySpec
return {
    'folke/tokyonight.nvim',
    lazy = config.theme ~= name,
    priority = 1000,
    opts = function()
        vim.g.lualine_theme = name
        return {
            style = 'night',
            transparent = config.transparent,
            terminal_colors = true,
            styles = {
                comments = 'italic',
                keywords = 'italic',
                functions = 'italic',
                variables = 'italic',
                sidebars = 'dark',
                floats = 'dark',
            },
            day_brightness = 0.3,
            hide_inactive_statusline = false,
            dim_inactive = false,
            lualine_bold = true,
            on_highlights = function(hl, c)
                hl.NotifyBackground = { bg = c.bg, fg = c.fg }
                -- hl.Cursor = { fg = c.black, bg = c.fg }
            end,
            on_colors = function(colors)
                -- colors.border = '#7aa2f7'
                colors.bg = '#07080D'
            end,
        }
    end,
    config = function(_, opts)
        require('tokyonight').setup(opts)
        require('tokyonight').load()
    end,
}

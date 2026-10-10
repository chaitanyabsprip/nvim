local config = require 'config.theme'
local syntax = require 'plugins.ui.themes.rosepine.highlights.syntax'
local name = 'rosepine'

local base = '#07080d'
local base_alt = '#0f111a'
local border = '#161721'
local hlt = '#131521'
local function make_border(fg)
    return {
        fg = fg or 'highlight_med',
        bg = 'base',
    }
end
local highlight = {
    ColorColumn = { bg = hlt },
    CursorLine = { bg = hlt },
    CursorLineNr = { bg = hlt, fg = 'text' },
    Comment = { fg = 'highlight_med', italic = true },
    CurSearch = { fg = 'base', bg = 'leaf', inherit = false },
    Search = { fg = 'text', bg = 'leaf', blend = 20, inherit = false },
    Folded = { fg = 'highlight_med', italic = true },
    BlinkCmpMenu = { bg = base, fg = 'text' },
    BlinkCmpMenuSelection = { bg = hlt },
    BlinkCmpScrollBarThumb = { bg = 'highlight_low' },
    BlinkCmpScrollBarGutter = { bg = base_alt },
    BlinkCmpLabelMatch = { fg = 'subtle' },
    BlinkCmpAbbr = { fg = 'subtle' },
    BlinkCmpAbbrDeprecated = { fg = 'subtle' },
    BlinkCmpAbbrMatch = { fg = 'iris' },
    BlinkCmpAbbrMatchFuzzy = { fg = 'iris' },
    BlinkCmpKind = { fg = 'base', bg = 'iris' },
    BlinkCmpKindClass = { fg = 'base', bg = 'gold' },
    BlinkCmpKindColor = { fg = 'base', bg = 'love' },
    BlinkCmpKindConstant = { fg = 'base', bg = 'rose' },
    BlinkCmpKindConstructor = { fg = 'base', bg = 'foam' },
    BlinkCmpKindCopilot = { fg = 'base', bg = 'iris' },
    BlinkCmpKindEnum = { fg = 'base', bg = 'pine' },
    BlinkCmpKindEnumMember = { fg = 'base', bg = 'love' },
    BlinkCmpKindEvent = { fg = 'base', bg = 'foam' },
    BlinkCmpKindField = { fg = 'base', bg = 'pine' },
    BlinkCmpKindFile = { fg = 'base', bg = 'foam' },
    BlinkCmpKindFolder = { fg = 'base', bg = 'foam' },
    BlinkCmpKindFunction = { fg = 'base', bg = 'iris' },
    BlinkCmpKindInterface = { fg = 'base', bg = 'gold' },
    BlinkCmpKindKeyword = { fg = 'base', bg = 'love' },
    BlinkCmpKindMethod = { fg = 'base', bg = 'iris' },
    BlinkCmpKindModule = { fg = 'base', bg = 'foam' },
    BlinkCmpKindOperator = { fg = 'base', bg = 'foam' },
    BlinkCmpKindProperty = { fg = 'base', bg = 'pine' },
    BlinkCmpKindReference = { fg = 'base', bg = 'love' },
    BlinkCmpKindSnippet = { fg = 'base', bg = 'iris' },
    BlinkCmpKindStruct = { fg = 'base', bg = 'foam' },
    BlinkCmpKindText = { fg = 'base', bg = 'iris' },
    BlinkCmpKindTypeParameter = { fg = 'base', bg = 'foam' },
    BlinkCmpKindUnit = { fg = 'base', bg = 'pine' },
    BlinkCmpKindValue = { fg = 'base', bg = 'rose' },
    BlinkCmpKindVariable = { fg = 'base', bg = 'foam' },
    FloatBorder = { fg = border, bg = 'base' },
    StatusLine = { fg = 'highlight_med', bg = 'none' },
    StatusLineNC = { fg = 'highlight_med', bg = 'none' },
    TelescopeBorder = { fg = border, bg = 'base' },
    TelescopeNormal = { bg = 'base', fg = 'muted' },
    TelescopePromptNormal = { fg = 'text', bg = 'base' },
    TelescopePromptBorder = { fg = border, bg = 'base' },
    TelescopePromptPrefix = { fg = 'love', bg = 'base' },
    TelescopePromptCounter = { fg = border, bg = 'base' },
    TelescopeMatching = { fg = 'rose' },
    TelescopeSelection = { fg = 'text', bg = 'base' },
    TelescopeSelectionCaret = { fg = 'iris', bg = 'base' },
    TelescopeTitle = { fg = 'muted', bg = 'love' },
    TelescopePreviewTitle = { fg = 'base', bg = 'iris' },
    TelescopePromptTitle = { fg = 'base', bg = 'love' },
    TelescopeResultsTitle = { fg = 'base', bg = 'foam' },
    TreesitterContext = { bg = base_alt },
    TreesitterContextLineNumber = { bg = base_alt },
    FzfLuaPreviewBorder = { link = 'TelescopeBorder' },
    Keyword = { link = 'Normal' },
    NonText = { fg = 'highlight_low' },
    NotifyBackground = { bg = 'base' },
    NotifyDEBUGBorder = make_border(),
    NotifyERRORBorder = make_border 'love',
    NotifyINFOBorder = make_border 'foam',
    NotifyTRACEBorder = make_border 'iris',
    NotifyWARNBorder = make_border 'gold',
    MatchParen = { fg = 'none', bg = 'highlight_med' },
    LeapBackdrop = { fg = '#545c7e' },
    Headline1 = { fg = 'iris', bg = 'base', bold = true },
    Headline2 = { fg = 'foam', bg = 'base', bold = true },
    Headline3 = { fg = 'rose', bg = 'base', bold = true },
    Headline4 = { fg = 'gold', bg = 'base', bold = true },
    Headline5 = { fg = 'pine', bg = 'base', bold = true },
    Headline6 = { fg = 'love', bg = 'base', bold = true },
    LspInlayHint = { fg = 'overlay', bg = 'base', blend = 0 },
}

highlight = vim.tbl_deep_extend('force', highlight, syntax)

---@type LazySpec
return {
    'rose-pine/neovim',
    name = 'rose-pine',
    lazy = config.theme ~= name,
    priority = 1000,
    opts = function()
        vim.g.lualine_theme = 'rose-pine'
        return {
            dark_variant = 'main',
            disable_float_background = true,
            highlight_groups = highlight,
            extend_background_behind_borders = true,
            enable = {
                terminal = true,
                legacy_highlights = true,
                migrations = true,
            },
            styles = { italic = true, transparency = config.transparent },
            ---@param highlights Highlight
            before_highlight = function(group, highlights, palette)
                if highlights.bg == palette.base then highlights.bg = base end
                if group == 'LspInlayHint' then highlights.blend = nil end
            end,
        }
    end,
    config = function(_, opts)
        require('rose-pine').setup(opts)
        vim.cmd.colorscheme 'rose-pine'
    end,
}

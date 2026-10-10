---@diagnostic disable: undefined-field
local M = {}

M.bufferline = {
    'akinsho/bufferline.nvim',
    version = '*',
    dependencies = 'nvim-tree/nvim-web-devicons',
    opts = function()
        return {
            options = {
                mode = 'tabs',
                style_preset = require('bufferline').style_preset.minimal,
                always_show_bufferline = false,
            },
        }
    end,
    event = #vim.fn.gettabinfo() > 1 and 'VeryLazy' or 'TabNew',
}

M.lualine = {
    'nvim-lualine/lualine.nvim',
    event = 'VeryLazy',
    opts = function()
        local function get_lsp_client(_)
            ---@type any?{}
            local client_names = {}
            local msg = 'No Active Lsp'
            local clients = vim.lsp.get_clients { bufnr = 0 }
            if next(clients) == nil then return msg end
            for _, client in ipairs(clients) do
                table.insert(client_names, client.name)
            end
            return #client_names == 0 and msg or table.concat(client_names, ' | ')
        end
        local function wordcount() return tostring(vim.fn.wordcount().words) .. ' words' end
        local function readingtime()
            return tostring(math.ceil(vim.fn.wordcount().words / 200.0)) .. ' min'
        end
        local function is_markdown()
            return vim.bo.filetype == 'markdown' or vim.bo.filetype == 'asciidoc'
        end
        local function navic() return require('nvim-navic').get_location() end
        local function navic_is_available()
            return package.loaded['nvim-navic'] and require('nvim-navic').is_available()
        end
        return {
            options = {
                component_separators = { '', '' },
                globalstatus = true,
                section_separators = '',
                theme = vim.g.lualine_theme or 'auto',
            },
            sections = {
                lualine_a = {
                    { 'filetype', icon_only = true, padding = { left = 1, right = 0 } },
                    { 'filename', newfile_status = true, path = 1 },
                },
                lualine_b = { 'diagnostics' },
                lualine_c = {
                    { navic, cond = navic_is_available },
                    { get_lsp_client, icon = '' },
                },
                lualine_x = {},
                lualine_y = {
                    { wordcount, cond = is_markdown },
                    { readingtime, cond = is_markdown },
                },
                lualine_z = { 'diff' },
            },
            extensions = { 'lazy', 'nvim-dap-ui', 'nvim-tree', 'c_quickfix' },
        }
    end,
}

return { M.bufferline, M.lualine, M.scope }

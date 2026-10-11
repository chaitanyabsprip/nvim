local lsp = {}

lsp.listLspCapabilities = function()
    local curBuf = vim.api.nvim_get_current_buf()
    local clients = vim.lsp.get_clients { bufnr = curBuf }

    for _, client in pairs(clients) do
        local capAsList = {}
        ---@type table<string, lsp.ClientCapabilities>
        local capabilities =
            vim.tbl_extend('keep', client.server_capabilities, client.dynamic_capabilities)
        for key, value in pairs(capabilities) do
            if value and key:find 'Provider' then
                local capability = key:gsub('Provider$', '')
                table.insert(capAsList, '- ' .. capability)
            end
        end
        table.sort(capAsList) -- sorts alphabetically
        local msg = '# ' .. client.name .. '\n' .. table.concat(capAsList, '\n')
        vim.notify(msg, vim.log.levels.INFO)
    end
end

---@param client vim.lsp.Client
---@param bufnr number
lsp.on_attach = function(client, bufnr)
    require('lsp.diagnostics').on_attach(client, bufnr)
    require('lsp.capabilities').resolve(client, bufnr)
end

return lsp

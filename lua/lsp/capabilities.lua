---@class Capability
---@field name string
---@field callback fun(client: vim.lsp.Client,bufnr: integer)
---@field note? string why it is unmapped, for the catalog at the bottom

---@type table<string,Capability>
local capabilities = {}
local augroup = function(group) vim.api.nvim_create_augroup(group, { clear = true }) end
local autocmd = function(event, opts)
    if not opts.disable then vim.api.nvim_create_autocmd(event, opts) end
end
local lsp = vim.lsp.buf

---@param opts LspFormat
local function format(opts)
    ---@type integer
    local buf = opts.bufnr
    if buf == nil then return end
    local null_ls_sources = require 'null-ls.sources'
    local ft = vim.bo[buf].filetype

    local has_null_ls = #null_ls_sources.get_available(ft, 'NULL_LS_FORMATTING') > 0
    ---@type function
    local filter = opts.filter
    opts.filter = nil
    vim.lsp.buf.format(vim.tbl_deep_extend('force', {
        bufnr = buf,
        filter = function(client)
            return (has_null_ls and client.name == 'null-ls')
                or not has_null_ls
                or (filter and filter())
        end,
    }, opts))
end

capabilities.code_action = {
    name = 'textDocument/codeAction',
    callback = function(_, bufnr)
        vim.keymap.set({ 'n', 'v' }, '<leader>a', require('fastaction').code_action, {
            buffer = bufnr,
            desc = 'Show code actions for the current cursor position or range selection',
            noremap = true,
            silent = true,
        })
    end,
}

capabilities.code_lens = {
    name = 'textDocument/codeLens',
    callback = function(_, bufnr)
        vim.keymap.set('n', '<leader>l', vim.lsp.codelens.run, {
            buffer = bufnr,
            desc = 'Run codelens on current line',
            noremap = true,
            silent = true,
        })
        vim.lsp.codelens.enable(true, { bufnr = bufnr })
    end,
}

capabilities.declaration = {
    name = 'textDocument/declaration',
    callback = function(_, bufnr)
        vim.keymap.set('n', 'gD', lsp.declaration, {
            buffer = bufnr,
            desc = 'Go to declaration of symbol under cursor',
            noremap = true,
            silent = true,
        })
    end,
}

capabilities.definition = {
    name = 'textDocument/definition',
    callback = function(_, bufnr)
        vim.keymap.set('n', 'gd', lsp.definition, {
            buffer = bufnr,
            desc = 'Go to definition of symbol under cursor',
            noremap = true,
            silent = true,
        })
    end,
}

capabilities.document_highlight = {
    name = 'textDocument/documentHighlight',
    callback = function(_, bufnr)
        local hl = vim.api.nvim_set_hl
        local folded = { link = 'Folded' }
        hl(0, 'LspReferenceRead', folded)
        hl(0, 'LspReferenceText', folded)
        hl(0, 'LspReferenceWrite', folded)
        local bold = { bold = true, bg = 'none' }
        hl(0, 'LspReferenceRead', bold)
        hl(0, 'LspReferenceText', bold)
        hl(0, 'LspReferenceWrite', bold)
        autocmd('CursorHold', {
            group = augroup 'lsp_document_highlight',
            buffer = bufnr,
            callback = function() vim.lsp.buf.document_highlight() end,
        })
        autocmd('CursorMoved', {
            group = augroup 'lsp_document_highlight',
            buffer = bufnr,
            callback = function() vim.lsp.buf.clear_references() end,
        })
    end,
}

capabilities.formatting = {
    name = 'textDocument/formatting',
    callback = function(_, bufnr)
        autocmd('BufWritePre', {
            group = augroup 'auto_format',
            buffer = bufnr,
            callback = function()
                format {
                    bufnr = bufnr,
                    async = false,
                    formatting_options = { tabSize = vim.bo[bufnr].tabstop },
                }
            end,
        })
    end,
}

capabilities.folding_range = {
    name = 'textDocument/foldingRange',
    callback = function(_, bufnr)
        for _, win in ipairs(vim.fn.win_findbuf(bufnr)) do
            vim.wo[win][0].foldexpr = vim.lsp.foldexpr
        end
    end,
}

capabilities.inlay_hints = {
    name = 'textDocument/inlayHint',
    callback = function(_, bufnr)
        local function toggle_inlay_hints()
            local ihint = vim.lsp.inlay_hint
            ihint.enable(not ihint.is_enabled { bufnr = bufnr }, { bufnr = bufnr })
        end
        vim.keymap.set('n', 'gi', toggle_inlay_hints, {
            buffer = bufnr,
            desc = 'Toggle inlay hints',
            noremap = true,
            silent = true,
        })
    end,
}

capabilities.inline_completion = {
    name = 'textDocument/inlineCompletion',
    callback = function(_, bufnr)
        vim.lsp.inline_completion.enable(true, { bufnr = bufnr })
        vim.keymap.set('i', '<Tab>', function()
            if not vim.lsp.inline_completion.get() then return '<Tab>' end
        end, {
            buffer = bufnr,
            desc = 'Accept the current inline completion',
            expr = true,
            noremap = true,
            silent = true,
        })
    end,
}

capabilities.linked_editing_range = {
    name = 'textDocument/linkedEditingRange',
    callback = function(_, bufnr) vim.lsp.linked_editing_range.enable(true, { bufnr = bufnr }) end,
}

capabilities.on_type_formatting = {
    name = 'textDocument/onTypeFormatting',
    callback = function(_, bufnr) vim.lsp.on_type_formatting.enable(true, { bufnr = bufnr }) end,
}

---@param bufnr integer
---@param mode "v"|"V"
---@return table {start={row,col}, end={row,col}} using (1, 0) indexing
local function range_from_selection(bufnr, mode)
    -- [bufnum, lnum, col, off]; both row and column 1-indexed
    local start = vim.fn.getpos 'v'
    local end_ = vim.fn.getpos '.'
    local start_row = start[2]
    local start_col = start[3]
    local end_row = end_[2]
    local end_col = end_[3]

    -- A user can start visual selection at the end and move backwards
    -- Normalize the range to start < end
    if start_row == end_row and end_col < start_col then
        end_col, start_col = start_col, end_col
    elseif end_row < start_row then
        start_row, end_row = end_row, start_row
    end
    if mode == 'V' then
        start_col = 1
        local lines = vim.api.nvim_buf_get_lines(bufnr, end_row - 1, end_row, true)
        end_col = #lines[1]
    end
    return {
        ['start'] = { start_row, start_col - 1 },
        ['end'] = { end_row, end_col - 1 },
    }
end

capabilities.range_formatting = {
    name = 'textDocument/rangeFormatting',
    callback = function(_, bufnr)
        vim.keymap.set('v', 'gf', function()
            format {
                bufnr = bufnr,
                range = range_from_selection(bufnr, vim.api.nvim_get_mode().mode),
                formatting_options = { tabSize = vim.bo[bufnr].tabstop },
                filter = function(client)
                    if client == nil then return end
                    return client:supports_method 'textDocument/rangeFormatting'
                end,
            }
        end, {
            noremap = true,
            silent = true,
            buffer = bufnr,
            desc = 'Range code formatting',
        })
    end,
}

capabilities.rename = {
    name = 'textDocument/rename',
    callback = function(client, bufnr)
        if client.name ~= 'dartls' then return end
        vim.keymap.set('n', 'gR', '<cmd>FlutterRename<cr>', {
            buffer = bufnr,
            desc = 'Flutter: Rename variable and related imports',
            noremap = true,
            silent = true,
        })
    end,
}

capabilities.signature_help = {
    name = 'textDocument/signatureHelp',
    callback = function(_, bufnr)
        vim.keymap.set('i', '<C-k>', vim.lsp.buf.signature_help, {
            buffer = bufnr,
            noremap = true,
            silent = true,
            desc = 'Show signature help',
        })
    end,
}

capabilities.symbol = {
    name = 'workspace/symbol',
    callback = function(_, bufnr)
        vim.keymap.set(
            'n',
            'gS',
            function() lsp.workspace_symbol(vim.fn.input { prompt = '> Search: ' }) end,
            {
                buffer = bufnr,
                desc = 'View Workspace symbols',
                noremap = true,
                silent = true,
            }
        )
    end,
}

capabilities.type_definition = {
    name = 'textDocument/typeDefinition',
    callback = function(_, bufnr)
        vim.keymap.set('n', '<leader>gnd', lsp.type_definition, {
            buffer = bufnr,
            desc = 'Show type definition of symbol under cursor',
            noremap = true,
            silent = true,
        })
    end,
}

-- Catalog of everything else a server can advertise. Each is a no-op: swap in
-- a `callback(client, bufnr)` to adopt one, and it starts resolving like the
-- entries above. `m.audit()` flags anything the protocol gains that is missing
-- from both lists.
local noop = function() end
local mapped = {}
for _, capability in pairs(capabilities) do
    mapped[capability.name] = true
end
for _, entry in ipairs {
    { 'textDocument/colorPresentation', 'paired with documentColor' },
    { 'textDocument/completion', 'blink owns completion' },
    { 'textDocument/diagnostic', 'pulled automatically' },
    { 'textDocument/documentColor', 'on by default since 0.12' },
    { 'textDocument/documentLink', 'gx opens the link under the cursor' },
    { 'textDocument/documentSymbol', 'builtin gO' },
    { 'textDocument/hover', 'builtin K' },
    { 'textDocument/implementation', 'builtin gri' },
    { 'textDocument/inlineValue', 'debugger-only, nothing renders it here' },
    { 'textDocument/moniker', 'cross-repo symbol ids, no local use' },
    { 'textDocument/prepareCallHierarchy', 'no mapping yet' },
    { 'textDocument/prepareRename', 'grn calls it on its own' },
    { 'textDocument/prepareTypeHierarchy', 'no mapping yet' },
    { 'textDocument/rangesFormatting', 'gf formats one range at a time' },
    { 'textDocument/references', 'builtin grr' },
    { 'textDocument/selectionRange', 'treesitter incremental selection instead' },
    { 'textDocument/semanticTokens/full', 'enabled by default on attach' },
    { 'textDocument/willSaveWaitUntil', 'BufWritePre formatting covers it' },
    { 'workspace/diagnostic', 'pulled automatically' },
    { 'workspace/didChangeWatchedFiles', 'nvim watches and notifies already' },
    { 'workspace/executeCommand', 'invoked by code actions and codelens' },
    { 'workspace/symbol', 'mapped above as gS' },
    { 'workspace/willCreateFiles', 'no file-op integration' },
    { 'workspace/willDeleteFiles', 'no file-op integration' },
    { 'workspace/willRenameFiles', 'no file-op integration' },
} do
    local method, note = entry[1], entry[2]
    if not mapped[method] then
        capabilities[method] = { name = method, callback = noop, note = note }
    end
end

---@type table<string,Capability|function>
local m = {}
-- calls function for each capability from a capabilities module if it's resolved
-- module name: the same as appropriate capability
-- module structure:
--     function(capability_value) - function to call if capability were resolved
---@param client vim.lsp.Client
---@param bufnr integer
m.resolve = function(client, bufnr)
    -- if client.name == 'basedpyright' then vim.print(client.server_capabilities) end
    for _, capability in pairs(capabilities) do
        if capability.callback ~= noop then
            local is_supported = client:supports_method(capability.name, 0)
            if is_supported then capability.callback(client, bufnr) end
        end
    end
end

-- every bindable method the protocol knows that neither list mentions, so the
-- catalog can't silently rot as neovim adds capabilities
---@return string[]
m.audit = function()
    local skip = '^%a+/did%a+$|^%a+/will%a+$|/refresh$|/resolve$'
    -- server->client, or sub-requests of a capability already listed
    local unbindable = {
        ['textDocument/publishDiagnostics'] = true,
        ['textDocument/semanticTokens/full/delta'] = true,
        ['textDocument/semanticTokens/range'] = true,
        ['workspace/applyEdit'] = true,
        ['workspace/configuration'] = true,
        ['workspace/textDocumentContent'] = true,
        ['workspace/workspaceFolders'] = true,
    }
    local missing = {}
    for _, method in pairs(vim.lsp.protocol.Methods) do
        local bindable = type(method) == 'string'
            and (vim.startswith(method, 'textDocument/') or vim.startswith(method, 'workspace/'))
            and not unbindable[method]
            and not vim.iter(vim.split(skip, '|')):any(function(p) return method:match(p) end)
        if bindable and not mapped[method] and not capabilities[method] then
            table.insert(missing, method)
        end
    end
    table.sort(missing)
    return missing
end

for k, v in pairs(capabilities) do
    m[k] = v
end

return m

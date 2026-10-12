local qf = {}

function qf.isloclist() return vim.fn.getloclist(0, { filewinid = 1 }).filewinid ~= 0 end

function qf.buffers()
    ---@type BufInfo[]
    local buffers = vim.fn.getbufinfo { buflisted = 1 }
    if #buffers == 0 then return vim.notify 'No listed buffers' end
    table.sort(buffers, function(a, b) return a.lastused > b.lastused end)
    ---@type QfItem[]
    local qfbufs = {}
    for _, buf in ipairs(buffers) do
        ---@type number, number
        local lnum, col = unpack(vim.api.nvim_buf_get_mark(buf.bufnr, '"'))
        table.insert(qfbufs, { bufnr = buf.bufnr, lnum = lnum, col = col })
    end
    vim.fn.setqflist(qfbufs, 'r')
    vim.g.qf_source = 'buffers'
    qf.toggle_qf()
end

function qf.toggle_qf()
    ---@diagnostic disable-next-line: no-unknown
    for _, info in ipairs(vim.fn.getwininfo()) do
        if info.quickfix == 1 then return vim.cmd 'cclose' end
    end
    if next(vim.fn.getqflist()) == nil then return vim.notify 'qf list empty' end
    vim.cmd 'copen'
end

function qf.toggle_ll()
    ---@diagnostic disable-next-line: no-unknown
    for _, info in ipairs(vim.fn.getwininfo()) do
        if info.loclist == 1 then return vim.cmd 'lclose' end
    end
    if next(vim.fn.getloclist(0)) == nil then return vim.notify 'loc list empty' end
    vim.cmd 'lopen'
end

function qf.delete_qf_entry()
    local qflist = vim.fn.getqflist()
    ---@diagnostic disable-next-line: no-unknown
    qflist = vim.tbl_filter(function(qfitem) return qfitem.bufnr ~= 0 end, qflist)
    if #qflist == 0 then return end
    if #qflist == 1 then
        qf.toggle_qf()
        vim.cmd.cfirst()
        return vim.fn.setqflist({}, 'r')
    end
    local lnum = vim.fn.line '.'
    if lnum == nil then return end
    table.remove(qflist, lnum)
    vim.fn.setqflist(qflist, 'r')
    if #qflist == 0 then return qf.toggle_qf() end
    vim.fn.cursor(lnum, 1)
end

function qf.delete_buf_from_qf()
    local lnum = vim.fn.line '.'
    ---@type QfItem[]
    local qflist = vim.fn.getqflist()
    local bufitem = qflist[lnum]
    local bufnr = bufitem.bufnr
    if bufnr ~= nil then vim.cmd.bdelete { count = bufnr } end
end

return qf

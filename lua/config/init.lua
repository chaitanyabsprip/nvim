---@diagnostic disable: no-unknown
local config = {}

function config.autocommands()
    local augroup = function(group) vim.api.nvim_create_augroup(group, { clear = true }) end
    local autocmd = function(event, opts)
        if not opts.disable then vim.api.nvim_create_autocmd(event, opts) end
    end

    autocmd('FileType', {
        group = augroup 'quit_mapping',
        pattern = { 'help', 'lspinfo', 'man', 'notify', 'qf', 'startuptime' },
        command = 'nnoremap <buffer> <silent> q <cmd>close<CR>',
    })

    autocmd('TextYankPost', {
        group = augroup 'highlight_yank',
        callback = function()
            require('vim.highlight').on_yank {
                higroup = 'Substitute',
                timeout = 1000,
                on_macro = true,
            }
        end,
    })

    autocmd('BufReadPre', {
        callback = function()
            if vim.bo.filetype == 'oil' then return end
            vim.api.nvim_exec_autocmds('User', { pattern = 'BufReadPreNotOil', modeline = false })
        end,
    })

    local restore_fold = augroup 'restore fold state'
    autocmd('BufWinLeave', { group = restore_fold, pattern = '?*', command = 'mkview 1' })
    autocmd('BufWinEnter', { group = restore_fold, pattern = '?*', command = 'silent! loadview 1' })

    autocmd({ 'FileType' }, {
        group = augroup 'fix_conceal',
        pattern = { 'json', 'jsonc' },
        callback = function()
            vim.wo.spell = false
            vim.wo.conceallevel = 0
        end,
    })

    autocmd('BufWritePre', {
        group = augroup 'eliminate_trailing_spaces',
        pattern = { 'markdown', 'md', 'rmd', 'rst' },
        command = [[%s/\s\+$//]],
    })

    autocmd('BufReadPre', {
        group = augroup 'syntax-and-filetype',
        once = true,
        command = [[
          syntax on
          filetype plugin indent on
        ]],
    })

    autocmd('CmdlineEnter', {
        group = augroup 'auto-disable-search-highlight',
        once = true,
        callback = function() require('search_highlight').setup() end,
    })

    autocmd('LspAttach', {
        group = augroup 'list-lsp-capabilities',
        callback = function()
            vim.api.nvim_create_user_command(
                'LspCapabilities',
                require('lsp').listLspCapabilities,
                {}
            )
        end,
    })

    local function update_lead()
        local lcs = vim.opt_local.listchars:get()
        local tab = vim.fn.str2list(lcs.tab)
        local space = vim.fn.str2list(lcs.multispace or lcs.space)
        local lead = { tab[1] }
        for i = 1, vim.bo.tabstop - 1 do
            lead[#lead + 1] = space[i % #space + 1]
        end
        vim.opt_local.listchars:append { leadmultispace = vim.fn.list2str(lead) }
    end
    autocmd(
        'OptionSet',
        { pattern = { 'listchars', 'tabstop', 'filetype' }, callback = update_lead }
    )
    autocmd('VimEnter', { callback = update_lead, once = true })
end

function config.disable_builtins()
    vim.cmd [[
    syntax off
    filetype off
  ]]

    -- Skip some remote provider loading
    -- vim.g.loaded_python3_provider = 0
    -- vim.g.loaded_node_provider = 0
    vim.g.loaded_perl_provider = 0
    vim.g.loaded_ruby_provider = 0
end

config.setup = function()
    -- moving around, searching and patterns
    vim.o.startofline = false
    vim.o.incsearch = true
    vim.o.ignorecase = true
    vim.o.smartcase = true
    vim.o.whichwrap = ''

    -- displaying text
    vim.o.scroll = 12 -- number of lines to scroll for CTRL-U and CTRL-D
    vim.o.smoothscroll = false
    vim.o.scrolloff = 8
    vim.o.wrap = false
    vim.opt.fillchars =
        { foldopen = '', foldclose = '', fold = ' ', foldsep = ' ', diff = '╱', eob = ' ' }
    vim.o.cmdheight = 0
    vim.o.lazyredraw = false -- don't redraw while executing macros
    vim.o.redrawtime = 600 -- timeout for 'hlsearch' and :match highlighting in msec
    vim.opt.list = true -- show <Tab> as ^I and end-of-line as $
    vim.opt.listchars =
        { tab = '| ', nbsp = '␣', trail = '•', extends = '⟩', precedes = '⟨', eol = '↲' }
    vim.o.number = true
    vim.o.relativenumber = true
    vim.o.numberwidth = 3
    vim.o.conceallevel = 2

    -- syntax, highlighting and spelling
    vim.o.background = 'dark'
    vim.o.hlsearch = false
    vim.o.termguicolors = true
    vim.o.cursorline = true
    vim.opt.cursorlineopt = { 'both' }
    vim.o.colorcolumn = '81'

    local rulerformat = '%=%c|%l [%P]'
    -- multiple windows
    vim.o.laststatus = 3
    -- vim.o.statuscolumn = [[%!v:lua.require'config.statuscolumn'.status_column()]]
    vim.o.statusline = string.format(' %s%s ', '%f', rulerformat)
    vim.o.splitbelow = true
    vim.o.splitright = true

    -- multiple tab pages
    vim.go.tabline = [[%!v:lua.require'config.tabline'.tabline()]]

    -- messages and info
    vim.o.shortmess = 'filnxtToOFIcCs'
    vim.opt.showcmdloc = 'statusline'
    vim.o.ruler = true
    vim.o.rulerformat = rulerformat

    -- selecting text
    vim.o.clipboard = 'unnamedplus'

    -- editing text
    vim.o.undofile = true
    vim.o.undodir = vim.fn.expand '~/.tmp/undodir'
    vim.o.textwidth = 72
    vim.opt.pumheight = 10
    vim.opt.showmatch = true

    -- tabs and indenting
    vim.o.tabstop = 8
    vim.o.expandtab = true
    vim.o.smarttab = true
    vim.o.softtabstop = 4
    vim.o.shiftwidth = 4
    vim.o.autoindent = true
    vim.o.smartindent = true

    -- folding
    vim.g.foldcolumn = false -- this is a custom option
    vim.o.foldlevel = 99
    vim.o.foldlevelstart = 99
    vim.o.foldmethod = 'expr'

    -- diff mode
    vim.opt.diffopt =
        { 'internal', 'filler', 'closeoff', 'algorithm:histogram', 'indent-heuristic' }

    -- reading and writing files
    vim.o.modeline = false
    vim.o.backup = false
    vim.o.writebackup = false

    -- the swap file
    vim.o.swapfile = false
    vim.o.updatetime = 1000

    -- executing external commands
    vim.o.shell = '/usr/bin/env zsh'

    -- running make and jumping to errors (quickfix)
    vim.go.grepprg = 'rg --vimgrep --no-heading --smart-case --multiline'
    vim.g.python3_host_prog = vim.fn.expand '~/.venvs/neovim/bin/python3'

    -- various
    vim.o.sessionoptions = 'buffers,curdir,winsize,resize,winpos,folds,tabpages,globals'
    vim.wo.signcolumn = 'yes'

    vim.opt.pumblend = 10

    -- sql plugin opts
    vim.g.ftplugin_sql_omni_key = '<c-a>'
end

-- mirror the live buffer to a temp file so `leaf -w` reloads on every edit
-- (nvim wipes its tempdir on exit; relative image paths won't resolve from there)
local leaf_mirrors = {}
local function leaf_mirror(buf)
    if leaf_mirrors[buf] then return leaf_mirrors[buf] end
    local dir = vim.fn.tempname()
    vim.fn.mkdir(dir, 'p')
    local mirror = dir .. '/' .. vim.fs.basename(vim.api.nvim_buf_get_name(buf))
    leaf_mirrors[buf] = mirror
    local group = vim.api.nvim_create_augroup('leaf_preview_' .. buf, { clear = true })
    local function sync() vim.fn.writefile(vim.api.nvim_buf_get_lines(buf, 0, -1, false), mirror) end
    sync()
    vim.api.nvim_create_autocmd(
        { 'TextChanged', 'TextChangedI' },
        { group = group, buffer = buf, callback = sync }
    )
    vim.api.nvim_create_autocmd('BufUnload', {
        group = group,
        buffer = buf,
        callback = function()
            os.remove(mirror)
            leaf_mirrors[buf] = nil
        end,
    })
    return mirror
end

local leaf_targets = {
    float = { 'display-popup', '-E', '-w', '100%', '-h', '100%' },
    window = { 'new-window' },
    split = { 'split-window', '-v' },
    vsplit = { 'split-window', '-h' },
}

config.commands = function()
    vim.api.nvim_create_user_command('Leaf', function(args)
        local target = leaf_targets[args.args ~= '' and args.args or 'float']
        if not target then
            return vim.notify('Unknown target: ' .. args.args, vim.log.levels.ERROR)
        end
        if vim.env.TMUX == nil then return vim.notify('Not inside tmux', vim.log.levels.WARN) end
        if vim.api.nvim_buf_get_name(0) == '' then
            return vim.notify('No file in buffer', vim.log.levels.WARN)
        end
        local cmd = vim.list_extend({ 'tmux' }, target)
        table.insert(cmd, 'leaf -w ' .. vim.fn.shellescape(leaf_mirror(0)))
        vim.system(cmd)
    end, {
        nargs = '?',
        desc = 'Preview current markdown file with leaf in tmux',
        complete = function() return vim.tbl_keys(leaf_targets) end,
    })
    vim.api.nvim_create_user_command(
        'Vnew',
        'vnew | setlocal nobuflisted buftype=nofile bufhidden=wipe noswapfile',
        {}
    )
    vim.api.nvim_create_user_command(
        'New',
        'new | setlocal nobuflisted buftype=nofile bufhidden=wipe noswapfile',
        {}
    )
end

function config.lazy()
    config.autocommands()
    config.commands()
    require('greeter').setup()
    require('config.tabline').setup()
    require('vim._core.ui2').enable { enable = true }
    -- require('utils').open_explorer_on_startup()
end

return config

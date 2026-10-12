vim.opt_local.autoindent = true
vim.opt_local.smartindent = false
vim.opt_local.smarttab = true
vim.opt_local.shiftwidth = 2
vim.opt_local.softtabstop = 2
vim.opt_local.formatoptions:append 'p'
vim.opt_local.comments = 'n:>'
vim.opt_local.list = true
vim.opt_local.listchars.nbsp = '_'
local formatlistpat = [[^\s*\d\+[.)\]}]\s\+\|^\s*[-*+]\s\+]]
vim.opt_local.formatlistpat = formatlistpat

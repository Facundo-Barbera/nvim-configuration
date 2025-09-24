-- Basic options
vim.opt.number = true
vim.opt.relativenumber = true

-- Split options
vim.opt.splitbelow = true
vim.opt.splitright = true

-- Tabulation options
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4

-- Enable mouse mode
vim.opt.mouse = "a"

-- Enable clipboard
vim.schedule(function()
	vim.opt.clipboard = "unnamedplus"
end)

-- Line breaks
vim.opt.linebreak = true
vim.opt.showbreak = "↪"

-- Show which line the cursor is at
vim.opt.cursorline = true

-- Search options
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Better error handling and responsiveness
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250

-- Better command line completion
vim.opt.wildmenu = true
vim.opt.wildmode = "longest:full,full"

-- Better scrolling
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8

-- Reduce command line messages (but allow errors to show)
vim.opt.shortmess:append("c") -- Don't show completion messages
vim.opt.shortmess:append("I") -- Don't show intro message
vim.opt.shortmess:append("W") -- Don't show written messages
vim.opt.shortmess:append("a") -- Abbreviate all messages
vim.opt.shortmess:append("t") -- Truncate long messages
vim.opt.shortmess:append("T") -- Truncate other messages in the middle
vim.opt.shortmess:append("s") -- Don't show search count messages like "[1/5]"
vim.opt.shortmess:append("F") -- Don't show file info when editing
vim.opt.shortmess:append("A") -- Don't show ATTENTION messages for existing swap files
vim.opt.shortmess:append("O") -- Don't show file read messages
vim.opt.shortmess:append("o") -- Overwrite file read messages
vim.opt.shortmess:append("S") -- Don't show search wrap messages
vim.opt.shortmess:append("q") -- Use "recording" instead of "recording @a"
vim.opt.shortmess:append("f") -- Use "(3 of 5)" instead of "(file 3 of 5)"

-- Additional message control
vim.opt.more = false -- Don't use more prompts
vim.opt.confirm = false -- Don't confirm dangerous actions
vim.opt.errorbells = false -- No error bells
vim.opt.visualbell = false -- No visual bells

-- Set command line height
vim.opt.cmdheight = 1

-- Enhanced undo functionality
vim.opt.undofile = true -- Enable persistent undo
vim.opt.undolevels = 10000 -- Maximum number of changes that can be undone
vim.opt.undoreload = 10000 -- Maximum number lines to save for undo on buffer reload
vim.opt.backup = false -- Don't create backup files (we have undo files)
vim.opt.writebackup = false -- Don't create backup before overwriting file
vim.opt.swapfile = false -- Don't use swap files (we have undo files)

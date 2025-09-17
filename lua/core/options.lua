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
vim.showbreak = "↪"

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


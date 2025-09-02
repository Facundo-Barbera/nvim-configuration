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


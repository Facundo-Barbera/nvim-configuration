-- Setup 'space' as <leader>
-- Useful for executing particular commands, must be setup before plugins.
vim.g.mapleader = " "
vim.g.maplocalleader = ","

-- Window navigation
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

-- Window management
vim.keymap.set("n", "<leader>wv", "<C-w>v", { desc = "Split window vertically" })
vim.keymap.set("n", "<leader>wh", "<C-w>s", { desc = "Split window horizontally" })
vim.keymap.set("n", "<leader>we", "<C-w>=", { desc = "Make splits equal size" })
vim.keymap.set("n", "<leader>wx", "<cmd>close<CR>", { desc = "Close current split" })

-- Buffer-to-split workflow (avoiding conflict with git hunks)
vim.keymap.set("n", "<leader>vs", "<C-w>v", { desc = "Open vertical split" })

-- Window resizing
vim.keymap.set("n", "<leader>w+", "<C-w>5+", { desc = "Increase window height" })
vim.keymap.set("n", "<leader>w-", "<C-w>5-", { desc = "Decrease window height" })
vim.keymap.set("n", "<leader>w>", "<C-w>5>", { desc = "Increase window width" })
vim.keymap.set("n", "<leader>w<", "<C-w>5<", { desc = "Decrease window width" })

-- Buffer navigation (simplified)
vim.keymap.set("n", "<S-h>", ":bprevious<CR>", { desc = "Previous buffer" })
vim.keymap.set("n", "<S-l>", ":bnext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "[b", ":bprevious<CR>", { desc = "Previous buffer" })
vim.keymap.set("n", "]b", ":bnext<CR>", { desc = "Next buffer" })
-- Buffer deletion handled by smart buffer manager (core.buffer_manager)
vim.keymap.set("n", "<leader>bn", ":bnext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<leader>bp", ":bprevious<CR>", { desc = "Previous buffer" })

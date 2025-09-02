vim.api.nvim_create_autocmd("BufEnter", {
	pattern = "*.pdf",
	callback = function()
		vim.cmd('silent !open "%"')
		vim.cmd("bdelete")
	end,
})

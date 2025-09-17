vim.api.nvim_create_autocmd("BufEnter", {
	pattern = "*.pdf",
	callback = function()
		vim.cmd('silent !open "%"')
		vim.cmd("bdelete")
	end,
})

-- Create :KnitHtml (Rmd → HTML in file's dir, then open it)
vim.api.nvim_create_user_command("KnitHtml", function()
	local input = vim.fn.expand("%:p")

	-- Check if current file is R Markdown
	if not input:match("%.Rmd$") and not input:match("%.rmd$") then
		vim.notify("KnitHtml only works with R Markdown files (.Rmd)", vim.log.levels.ERROR)
		return
	end

	-- Check if Rscript is available
	if vim.fn.executable("Rscript") == 0 then
		vim.notify("Rscript not found. Please install R.", vim.log.levels.ERROR)
		return
	end

	local dir = vim.fn.expand("%:p:h")
	local out = vim.fn.expand("%:p:r") .. ".html"

	local cmd = string.format(
		[[Rscript -e "rmarkdown::render(%q, output_format='html_document', knit_root_dir=dirname(normalizePath(%q)), output_dir=dirname(normalizePath(%q)))"]],
		input,
		input,
		input
	)

	-- Cross-platform file opening
	local open_cmd = vim.fn.has("mac") == 1 and "open" or
	                vim.fn.has("unix") == 1 and "xdg-open" or "start"

	-- Run render and wait for completion before opening
	vim.fn.jobstart(cmd, {
		detach = false,
		on_exit = function(_, exit_code)
			if exit_code == 0 then
				vim.fn.jobstart({ open_cmd, out }, { detach = true })
			else
				vim.notify("R Markdown render failed", vim.log.levels.ERROR)
			end
		end
	})
end, {})

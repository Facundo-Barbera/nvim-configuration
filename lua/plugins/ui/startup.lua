return {
	"startup-nvim/startup.nvim",
	dependencies = {
		"nvim-telescope/telescope.nvim",
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons",
	},
	config = function()
		local startup = require("startup")
		startup.setup({
			header = {
				type = "text",
				oldfiles_directory = false,
				align = "center",
				fold_section = false,
				title = "Header",
				margin = 5,
				content = {
					" ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗",
					" ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║",
					" ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║",
					" ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║",
					" ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║",
					" ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝",
				},
				highlight = "Statement",
				default_color = "",
				oldfiles_amount = 0,
			},
			body = {
				type = "mapping",
				oldfiles_directory = false,
				align = "center",
				fold_section = false,
				title = "Basic Commands",
				margin = 5,
				content = {
					{ " Find File", "Telescope find_files", "<leader>ff" },
					{ " File Browser", "NvimTreeToggle", "<leader>e" },
					{ " Find Word", "Telescope live_grep", "<leader>fg" },
					{ " Recent Files", "Telescope oldfiles", "<leader>fr" },
					{ " Colorschemes", "Telescope colorscheme", "<leader>cs" },
					{ " New File", "lua require'startup'.new_file()", "<leader>nf" },
				},
				highlight = "String",
				default_color = "",
				oldfiles_amount = 0,
			},
			footer = {
				type = "text",
				oldfiles_directory = false,
				align = "center",
				fold_section = false,
				title = "Footer",
				margin = 5,
				content = {
					"Welcome to Neovim "
						.. vim.version().major
						.. "."
						.. vim.version().minor
						.. "."
						.. vim.version().patch,
				},
				highlight = "Number",
				default_color = "",
				oldfiles_amount = 0,
			},

			options = {
				mapping_keys = true,
				cursor_column = 0.5,
				empty_lines_between_mappings = true,
				disable_statuslines = true,
				paddings = { 1, 3, 3, 0 },
			},
			mappings = {
				execute_command = "<CR>",
				open_file = "o",
				open_file_split = "<c-o>",
				open_section = "<TAB>",
				open_help = "?",
			},
			colors = {
				background = "#1f2227",
				folded_section = "#56b6c2",
			},
			parts = { "header", "body", "footer" },
		})

		-- Custom autocommand to show startup when opening directories
		-- Add safety guards to prevent conflicts with lazy.nvim and other operations
		local function is_safe_to_show_startup()
			-- Don't show during plugin operations
			if vim.g.lazy_loading or vim.g.lazy_updating then
				return false
			end

			-- Don't show if we're in a lazy.nvim buffer
			local current_buf = vim.api.nvim_get_current_buf()
			local ft = vim.api.nvim_get_option_value("filetype", { buf = current_buf })
			if ft == "lazy" then
				return false
			end

			-- Don't show if lazy.nvim UI is open
			for _, win in ipairs(vim.api.nvim_list_wins()) do
				local buf = vim.api.nvim_win_get_buf(win)
				local buf_ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
				if buf_ft == "lazy" then
					return false
				end
			end

			return true
		end

		vim.api.nvim_create_autocmd("VimEnter", {
			callback = function()
				-- Check if we opened a directory or multiple files
				local args = vim.fn.argv()
				if #args == 1 then
					local path = args[1]
					-- If the argument is a directory, show startup
					if vim.fn.isdirectory(path) == 1 then
						-- Change to the directory first
						vim.cmd("cd " .. vim.fn.fnameescape(path))
						-- Use a longer delay to ensure everything is ready
						vim.defer_fn(function()
							-- Safety check before proceeding
							if not is_safe_to_show_startup() then
								return
							end

							-- Check if we're still in the directory buffer
							local current_buf = vim.api.nvim_get_current_buf()
							local buf_name = vim.api.nvim_buf_get_name(current_buf)

							-- Only proceed if we're still looking at a directory
							if vim.fn.isdirectory(buf_name) == 1 or buf_name == path then
								-- Create a new buffer and switch to it
								local new_buf = vim.api.nvim_create_buf(false, true)
								vim.api.nvim_set_current_buf(new_buf)

								-- Small additional delay before displaying startup
								vim.defer_fn(function()
									if is_safe_to_show_startup() then
										local ok, err = pcall(startup.display)
										if not ok then
											-- Fallback: just open nvim-tree if startup fails
											vim.notify("Startup screen failed, opening file explorer", vim.log.levels.WARN)
											vim.cmd("NvimTreeOpen")
										end
									end
								end, 50)
							end
						end, 200)
					end
				end
			end,
		})

		-- Also handle cases where someone opens a directory buffer later
		vim.api.nvim_create_autocmd("BufEnter", {
			callback = function()
				-- Safety check first
				if not is_safe_to_show_startup() then
					return
				end

				-- Check if the current buffer is a directory
				local bufname = vim.api.nvim_buf_get_name(0)
				if bufname ~= "" and vim.fn.isdirectory(bufname) == 1 then
					-- Change to the directory
					vim.cmd("cd " .. vim.fn.fnameescape(bufname))
					-- Use proper timing to avoid cursor issues
					vim.defer_fn(function()
						if is_safe_to_show_startup() then
							-- Create new buffer and display startup
							local new_buf = vim.api.nvim_create_buf(false, true)
							vim.api.nvim_set_current_buf(new_buf)

							vim.defer_fn(function()
								if is_safe_to_show_startup() then
									local ok, err = pcall(startup.display)
									if not ok then
										-- Fallback: just open nvim-tree if startup fails
										vim.notify("Startup screen failed, opening file explorer", vim.log.levels.WARN)
										vim.cmd("NvimTreeOpen")
									end
								end
							end, 50)
						end
					end, 100)
				end
			end,
		})
	end,
}

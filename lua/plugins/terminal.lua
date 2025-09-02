-- lua/plugins/terminal.lua
return {
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		keys = {
			{ "<C-\\>", desc = "Toggle terminal" },
			{ "<leader>th", desc = "Toggle horizontal terminal" },
			{ "<leader>tv", desc = "Toggle vertical terminal" },
			{ "<leader>tf", desc = "Toggle floating terminal" },
			{ "<leader>tg", desc = "Toggle lazygit" },
			{ "<leader>tp", desc = "Toggle Python REPL" },
			{ "<leader>tr", desc = "Toggle R console" },
		},
		config = function()
			require("toggleterm").setup({
				size = function(term)
					if term.direction == "horizontal" then
						return 15
					elseif term.direction == "vertical" then
						return vim.o.columns * 0.4
					end
				end,
				open_mapping = [[<c-\>]],
				hide_numbers = true,
				shade_terminals = true,
				start_in_insert = true,
				insert_mappings = true,
				terminal_mappings = true,
				persist_size = true,
				direction = "horizontal",
				close_on_exit = true,
				shell = vim.o.shell,
				winbar = {
					enabled = false,
				},
				float_opts = {
					border = "curved",
					width = 120,
					height = 30,
				},
			})

			local Terminal = require("toggleterm.terminal").Terminal

			-- General terminals
			local horizontal_term = Terminal:new({ direction = "horizontal", hidden = true })
			local vertical_term = Terminal:new({ direction = "vertical", hidden = true })
			local floating_term = Terminal:new({ direction = "float", hidden = true })

			-- Specialized terminals
			local lazygit = Terminal:new({
				cmd = "lazygit",
				direction = "float",
				float_opts = { width = 120, height = 40 },
				hidden = true,
			})

			local python_repl = Terminal:new({
				cmd = "python3",
				direction = "horizontal",
				hidden = true,
			})

			local r_console = Terminal:new({
				cmd = "R --quiet --no-save",
				direction = "horizontal",
				hidden = true,
			})

			-- Toggle functions
			function _HORIZONTAL_TOGGLE()
				horizontal_term:toggle()
			end
			function _VERTICAL_TOGGLE()
				vertical_term:toggle()
			end
			function _FLOAT_TOGGLE()
				floating_term:toggle()
			end
			function _LAZYGIT_TOGGLE()
				lazygit:toggle()
			end
			function _PYTHON_TOGGLE()
				python_repl:toggle()
			end
			function _R_TOGGLE()
				r_console:toggle()
			end

			-- Key mappings (your existing <C-hjkl> will work automatically)
			vim.keymap.set({ "n", "t" }, "<C-\\>", _HORIZONTAL_TOGGLE, { desc = "Toggle terminal" })
			vim.keymap.set("n", "<leader>th", _HORIZONTAL_TOGGLE, { desc = "Horizontal terminal" })
			vim.keymap.set("n", "<leader>tv", _VERTICAL_TOGGLE, { desc = "Vertical terminal" })
			vim.keymap.set("n", "<leader>tf", _FLOAT_TOGGLE, { desc = "Floating terminal" })
			vim.keymap.set("n", "<leader>tg", _LAZYGIT_TOGGLE, { desc = "LazyGit" })
			vim.keymap.set("n", "<leader>tp", _PYTHON_TOGGLE, { desc = "Python REPL" })
			vim.keymap.set("n", "<leader>tr", _R_TOGGLE, { desc = "R Console" })

			-- Just the escape mapping for convenience
			vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { silent = true })
		end,
	},
}

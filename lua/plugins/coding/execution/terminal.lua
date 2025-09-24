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

			-- Custom run commands for different file types
			local function run_current_file()
				local ft = vim.bo.filetype
				local file = vim.fn.expand("%:p")
				local filename = vim.fn.expand("%:t")

				local runners = {
					python = function()
						return "python3 " .. vim.fn.shellescape(file)
					end,
					javascript = function()
						return "node " .. vim.fn.shellescape(file)
					end,
					typescript = function()
						return "ts-node " .. vim.fn.shellescape(file)
					end,
					lua = function()
						return "lua " .. vim.fn.shellescape(file)
					end,
					r = function()
						return "Rscript " .. vim.fn.shellescape(file)
					end,
					sh = function()
						return "bash " .. vim.fn.shellescape(file)
					end,
					zsh = function()
						return "zsh " .. vim.fn.shellescape(file)
					end,
					go = function()
						return "go run " .. vim.fn.shellescape(file)
					end,
					rust = function()
						local name = vim.fn.expand("%:t:r")
						return string.format("rustc %s && ./%s", vim.fn.shellescape(file), vim.fn.shellescape(name))
					end,
					c = function()
						local name = vim.fn.expand("%:t:r")
						return string.format(
							"gcc %s -o %s && ./%s",
							vim.fn.shellescape(file),
							vim.fn.shellescape(name),
							vim.fn.shellescape(name)
						)
					end,
					cpp = function()
						local name = vim.fn.expand("%:t:r")
						return string.format(
							"g++ %s -o %s && ./%s",
							vim.fn.shellescape(file),
							vim.fn.shellescape(name),
							vim.fn.shellescape(name)
						)
					end,
					java = function()
						local name = vim.fn.expand("%:t:r")
						return string.format(
							"javac %s && java %s",
							vim.fn.shellescape(filename),
							vim.fn.shellescape(name)
						)
					end,
					html = function()
						local open_cmd = vim.fn.has("mac") == 1 and "open"
							or vim.fn.has("unix") == 1 and "xdg-open"
							or "start"
						return string.format("%s %s", open_cmd, vim.fn.shellescape(file))
					end,
					markdown = function()
						local output = vim.fn.expand("%:p:r") .. ".html"
						local open_cmd = vim.fn.has("mac") == 1 and "open"
							or vim.fn.has("unix") == 1 and "xdg-open"
							or "start"
						if vim.fn.executable("pandoc") == 1 then
							return string.format(
								"pandoc %s -o %s && %s %s",
								vim.fn.shellescape(file),
								vim.fn.shellescape(output),
								open_cmd,
								vim.fn.shellescape(output)
							)
						else
							return string.format("%s %s", open_cmd, vim.fn.shellescape(file))
						end
					end,
				}

				local runner = runners[ft]
				if runner then
					local cmd = runner()
					-- Send command to existing horizontal terminal or create new one
					horizontal_term:toggle()
					vim.defer_fn(function()
						horizontal_term:send(cmd)
					end, 100)
				else
					vim.notify("No runner configured for filetype: " .. ft, vim.log.levels.WARN)
				end
			end

			-- Language-specific terminal functions
			local function run_in_repl(lang, code)
				local terminals = {
					python = python_repl,
					r = r_console,
				}

				local term = terminals[lang]
				if term then
					term:toggle()
					vim.defer_fn(function()
						term:send(code)
					end, 100)
				else
					vim.notify("No REPL available for: " .. lang, vim.log.levels.WARN)
				end
			end

			-- Quick run current file
			vim.keymap.set("n", "<leader>rq", run_current_file, { desc = "Quick run current file" })

			-- Send current line to REPL
			vim.keymap.set("n", "<leader>rl", function()
				local ft = vim.bo.filetype
				local line = vim.api.nvim_get_current_line()
				run_in_repl(ft, line)
			end, { desc = "Send current line to REPL" })

			-- Send selection to REPL
			vim.keymap.set("v", "<leader>rs", function()
				local ft = vim.bo.filetype
				-- Get visual selection
				local start_pos = vim.fn.getpos("'<")
				local end_pos = vim.fn.getpos("'>")
				local lines = vim.fn.getline(start_pos[2], end_pos[2])
				local code = table.concat(lines, "\n")
				run_in_repl(ft, code)
			end, { desc = "Send selection to REPL" })

			-- Project runners (detect and run based on project files)
			local function run_project()
				local cwd = vim.fn.getcwd()
				local project_runners = {
					["package.json"] = "npm start",
					["Cargo.toml"] = "cargo run",
					["go.mod"] = "go run .",
					["Makefile"] = "make run",
					["requirements.txt"] = "pip install -r requirements.txt",
					["pyproject.toml"] = "python -m pip install -e .",
					["setup.py"] = "python setup.py install",
				}

				for file, cmd in pairs(project_runners) do
					if vim.fn.filereadable(cwd .. "/" .. file) == 1 then
						horizontal_term:toggle()
						vim.defer_fn(function()
							horizontal_term:send(cmd)
						end, 100)
						return
					end
				end

				vim.notify("No project runner found. Add package.json, Cargo.toml, etc.", vim.log.levels.WARN)
			end

			vim.keymap.set("n", "<leader>rp", run_project, { desc = "Run project" })
		end,
	},
}

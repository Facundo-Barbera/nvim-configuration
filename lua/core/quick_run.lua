-- Quick run functionality for various file types
-- This provides simple, fast execution without opening terminals

return {
	-- Simple function to create quick run commands
	setup = function()
		-- Quick run current file with output in a floating window
		local function quick_run_file()
			local ft = vim.bo.filetype
			local file = vim.fn.expand("%:p")
			local filename = vim.fn.expand("%:t")

			-- Language-specific runners that capture output
			local runners = {
				python = function()
					return { "python3", file }
				end,
				javascript = function()
					return { "node", file }
				end,
				typescript = function()
					return { "ts-node", file }
				end,
				lua = function()
					-- For lua files, use luafile if it's a neovim config, otherwise lua command
					if file:match("nvim") or file:match("config") then
						vim.cmd("luafile " .. file)
						vim.notify("Executed lua file in Neovim", vim.log.levels.INFO)
						return nil -- Don't run external command
					else
						return { "lua", file }
					end
				end,
				r = function()
					return { "Rscript", file }
				end,
				sh = function()
					return { "bash", file }
				end,
				zsh = function()
					return { "zsh", file }
				end,
				go = function()
					return { "go", "run", file }
				end,
				java = function()
					-- Compile and run Java
					local name = vim.fn.expand("%:t:r")
					local compile_result = vim.fn.system(string.format("javac %s", vim.fn.shellescape(filename)))
					if vim.v.shell_error ~= 0 then
						return nil, "Compilation failed: " .. compile_result
					end
					return { "java", name }
				end,
				php = function()
					return { "php", file }
				end,
				ruby = function()
					return { "ruby", file }
				end,
				perl = function()
					return { "perl", file }
				end,
			}

			local runner = runners[ft]
			if not runner then
				vim.notify("No quick runner available for filetype: " .. ft, vim.log.levels.WARN)
				return
			end

			local cmd, error_msg = runner()
			if error_msg then
				vim.notify(error_msg, vim.log.levels.ERROR)
				return
			end

			if not cmd then
				return -- Already handled (like lua files)
			end

			-- Save the file first
			vim.cmd("write")

			-- Execute and capture output
			local output = vim.fn.system(cmd)
			local exit_code = vim.v.shell_error

			-- Create floating window with output
			local lines = vim.split(output, "\n")
			local width = math.floor(vim.o.columns * 0.8)
			local height = math.min(#lines + 5, math.floor(vim.o.lines * 0.8))
			local row = math.floor((vim.o.lines - height) / 2)
			local col = math.floor((vim.o.columns - width) / 2)

			local buf = vim.api.nvim_create_buf(false, true)

			-- Add header with file info and exit code
			local header = {
				string.format("Output for: %s", filename),
				string.format("Exit code: %d", exit_code),
				string.rep("─", 50),
				"",
			}
			local all_lines = vim.list_extend(header, lines)
			vim.api.nvim_buf_set_lines(buf, 0, -1, false, all_lines)

			-- Set buffer options
			vim.api.nvim_buf_set_option(buf, "readonly", true)
			vim.api.nvim_buf_set_option(buf, "modifiable", false)
			vim.api.nvim_buf_set_option(buf, "filetype", "output")

			-- Create window
			local title = exit_code == 0 and "✓ Output" or "✗ Output (Error)"
			local title_hl = exit_code == 0 and "DiagnosticOk" or "DiagnosticError"

			local opts = {
				relative = "editor",
				width = width,
				height = height,
				row = row,
				col = col,
				style = "minimal",
				border = "rounded",
				title = title,
				title_pos = "center",
			}

			local win = vim.api.nvim_open_win(buf, true, opts)
			vim.api.nvim_win_set_option(win, "wrap", true)

			-- Set title highlight
			vim.api.nvim_set_hl(0, "FloatTitle", { link = title_hl })

			-- Close on escape or q
			local close_keys = { "<Esc>", "q", "<CR>" }
			for _, key in ipairs(close_keys) do
				vim.keymap.set("n", key, "<cmd>q<cr>", { buffer = buf, silent = true })
			end

			-- Show notification
			local level = exit_code == 0 and vim.log.levels.INFO or vim.log.levels.ERROR
			local msg = exit_code == 0 and "Execution completed successfully" or "Execution failed"
			vim.notify(msg, level)
		end

		-- Quick compile for compiled languages
		local function quick_compile()
			local ft = vim.bo.filetype
			local file = vim.fn.expand("%:p")
			local filename = vim.fn.expand("%:t")
			local name = vim.fn.expand("%:t:r")

			local compilers = {
				c = function()
					return { "gcc", file, "-o", name }
				end,
				cpp = function()
					return { "g++", file, "-o", name }
				end,
				rust = function()
					return { "rustc", file }
				end,
				go = function()
					return { "go", "build", file }
				end,
				java = function()
					return { "javac", filename }
				end,
			}

			local compiler = compilers[ft]
			if not compiler then
				vim.notify("No compiler available for filetype: " .. ft, vim.log.levels.WARN)
				return
			end

			-- Save the file first
			vim.cmd("write")

			local cmd = compiler()
			local output = vim.fn.system(cmd)
			local exit_code = vim.v.shell_error

			if exit_code == 0 then
				vim.notify("Compilation successful", vim.log.levels.INFO)
			else
				vim.notify("Compilation failed: " .. output, vim.log.levels.ERROR)
			end
		end

		-- Test runners for different languages
		local function quick_test()
			local ft = vim.bo.filetype
			local file = vim.fn.expand("%:p")
			local cwd = vim.fn.getcwd()

			local test_runners = {
				python = function()
					-- Check for pytest, unittest, or nose
					if
						vim.fn.filereadable(cwd .. "/pytest.ini") == 1
						or vim.fn.filereadable(cwd .. "/pyproject.toml") == 1
					then
						return { "pytest", file }
					elseif file:match("test_") or file:match("_test") then
						return { "python3", "-m", "unittest", file }
					else
						return { "python3", "-m", "doctest", file }
					end
				end,
				javascript = function()
					-- Check for package.json test script
					if vim.fn.filereadable(cwd .. "/package.json") == 1 then
						return { "npm", "test", file }
					else
						return { "node", file }
					end
				end,
				go = function()
					return { "go", "test", "-v", file }
				end,
				rust = function()
					return { "cargo", "test" }
				end,
				r = function()
					return { "Rscript", "-e", string.format("testthat::test_file('%s')", file) }
				end,
			}

			local runner = test_runners[ft]
			if not runner then
				vim.notify("No test runner available for filetype: " .. ft, vim.log.levels.WARN)
				return
			end

			-- Save the file first
			vim.cmd("write")

			local cmd = runner()
			local output = vim.fn.system(cmd)
			local exit_code = vim.v.shell_error

			-- Show results
			local level = exit_code == 0 and vim.log.levels.INFO or vim.log.levels.ERROR
			local msg = exit_code == 0 and "Tests passed" or "Tests failed"
			vim.notify(msg .. "\n" .. output, level)
		end

		-- Benchmark/profiling runners
		local function quick_profile()
			local ft = vim.bo.filetype
			local file = vim.fn.expand("%:p")

			local profilers = {
				python = function()
					return { "python3", "-m", "cProfile", file }
				end,
				r = function()
					return { "Rscript", "-e", string.format("profvis::profvis(source('%s'))", file) }
				end,
				javascript = function()
					return { "node", "--prof", file }
				end,
			}

			local profiler = profilers[ft]
			if not profiler then
				vim.notify("No profiler available for filetype: " .. ft, vim.log.levels.WARN)
				return
			end

			-- Save the file first
			vim.cmd("write")

			local cmd = profiler()
			local output = vim.fn.system(cmd)
			vim.notify("Profiling completed:\n" .. output, vim.log.levels.INFO)
		end

		-- Key mappings
		vim.keymap.set("n", "<F5>", quick_run_file, { desc = "Quick run file" })
		vim.keymap.set("n", "<F6>", quick_compile, { desc = "Quick compile" })
		vim.keymap.set("n", "<F7>", quick_test, { desc = "Quick test" })
		vim.keymap.set("n", "<F8>", quick_profile, { desc = "Quick profile" })
		vim.keymap.set("n", "<leader>rP", quick_profile, { desc = "Quick profile" })

		-- Run with arguments
		vim.keymap.set("n", "<leader>ra", function()
			local ft = vim.bo.filetype
			local file = vim.fn.expand("%:p")
			local args = vim.fn.input("Arguments: ")

			if ft == "python" then
				vim.cmd("!" .. "python3 " .. vim.fn.shellescape(file) .. " " .. args)
			elseif ft == "javascript" then
				vim.cmd("!" .. "node " .. vim.fn.shellescape(file) .. " " .. args)
			elseif ft == "r" then
				vim.cmd("!" .. "Rscript " .. vim.fn.shellescape(file) .. " " .. args)
			else
				vim.notify("Arguments not supported for filetype: " .. ft, vim.log.levels.WARN)
			end
		end, { desc = "Run with arguments" })

		local function quick_lint()
			local ft = vim.bo.filetype
			local file = vim.fn.expand("%:p")

			local linters = {
				python = function()
					return { "flake8", file }
				end,
				javascript = function()
					return { "eslint", file }
				end,
				typescript = function()
					return { "eslint", file }
				end,
				r = function()
					return { "Rscript", "-e", string.format("lintr::lint('%s')", file) }
				end,
				sh = function()
					return { "shellcheck", file }
				end,
				lua = function()
					return { "luacheck", file }
				end,
			}

			local linter = linters[ft]
			if not linter then
				vim.notify("No linter available for filetype: " .. ft, vim.log.levels.WARN)
				return
			end

			local cmd = linter()
			local output = vim.fn.system(cmd)
			local exit_code = vim.v.shell_error

			if exit_code == 0 then
				vim.notify("No linting errors found", vim.log.levels.INFO)
			else
				vim.notify("Linting issues found:\n" .. output, vim.log.levels.WARN)
			end
		end

		local function quick_format()
			local ft = vim.bo.filetype
			local file = vim.fn.expand("%:p")

			local formatters = {
				python = function()
					vim.fn.system({ "black", file })
					vim.cmd("edit!") -- Reload file
					return "Formatted with black"
				end,
				javascript = function()
					vim.fn.system({ "prettier", "--write", file })
					vim.cmd("edit!")
					return "Formatted with prettier"
				end,
				typescript = function()
					vim.fn.system({ "prettier", "--write", file })
					vim.cmd("edit!")
					return "Formatted with prettier"
				end,
				go = function()
					vim.fn.system({ "gofmt", "-w", file })
					vim.cmd("edit!")
					return "Formatted with gofmt"
				end,
				rust = function()
					vim.fn.system({ "rustfmt", file })
					vim.cmd("edit!")
					return "Formatted with rustfmt"
				end,
				r = function()
					vim.fn.system({ "Rscript", "-e", string.format("styler::style_file('%s')", file) })
					vim.cmd("edit!")
					return "Formatted with styler"
				end,
			}

			local formatter = formatters[ft]
			if not formatter then
				vim.notify("No formatter available for filetype: " .. ft, vim.log.levels.WARN)
				return
			end

			local msg = formatter()
			vim.notify(msg, vim.log.levels.INFO)
		end

		-- Create user commands
		vim.api.nvim_create_user_command("QuickRun", quick_run_file, {})
		vim.api.nvim_create_user_command("QuickCompile", quick_compile, {})
		vim.api.nvim_create_user_command("QuickTest", quick_test, {})
		vim.api.nvim_create_user_command("QuickProfile", quick_profile, {})
		vim.api.nvim_create_user_command("QuickLint", quick_lint, {})
		vim.api.nvim_create_user_command("QuickFormat", quick_format, {})
	end,
}

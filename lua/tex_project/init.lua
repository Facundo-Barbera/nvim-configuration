-- TeX Project Management for Neovim
-- Provides utilities for creating and managing LaTeX projects

local M = {}

-- Cache for project configurations
local project_cache = {}

-- Check if a file exists
local function file_exists(path)
	local f = io.open(path, "r")
	if f then
		f:close()
		return true
	end
	return false
end

-- Load project configuration from .texproject.json
local function load_project_config(dir)
	dir = dir or vim.fn.getcwd()
	local config_path = vim.fn.resolve(dir .. "/.texproject.json")

	if project_cache[config_path] then
		return project_cache[config_path]
	end

	if file_exists(config_path) then
		local content = vim.fn.readfile(config_path)
		if content and #content > 0 then
			local ok, config = pcall(vim.json.decode, table.concat(content, "\n"))
			if ok and config then
				project_cache[config_path] = config
				return config
			end
		end
	end

	return nil
end

-- Get available templates from the templates directory
local function get_available_templates()
	local templates = {}
	local config_dir = vim.fn.stdpath("config")
	local templates_dir = config_dir .. "/lua/tex_project/templates"

	if not file_exists(templates_dir) then
		-- Fallback to built-in template if templates directory doesn't exist
		return { { name = "article (built-in)", file = nil } }
	end

	local handle = vim.loop.fs_scandir(templates_dir)
	if handle then
		while true do
			local name, type = vim.loop.fs_scandir_next(handle)
			if not name then
				break
			end
			if type == "file" and name:match("%.tex$") then
				local template_name = name:gsub("%.tex$", "")
				table.insert(templates, {
					name = template_name,
					file = templates_dir .. "/" .. name,
				})
			end
		end
	end

	-- Sort templates alphabetically
	table.sort(templates, function(a, b)
		return a.name < b.name
	end)

	-- Add built-in fallback if no templates found
	if #templates == 0 then
		table.insert(templates, { name = "article (built-in)", file = nil })
	end

	return templates
end

-- Read and process template file with variable substitution
local function process_template(template_file, variables)
	if not template_file or not file_exists(template_file) then
		-- Fallback to built-in template
		local current_date = vim.fn.strftime("%Y-%m-%d")
		return {
			string.format("%%! Author: %s", variables.author),
			string.format("%%! Date: %s", current_date),
			string.format("%%! TEX root = %s.tex", variables.filename),
			"",
			"\\documentclass{article}",
			string.format("\\title{%s}", variables.title or variables.filename),
			string.format("\\author{%s}", variables.author),
			"\\date{\\today}",
			"\\begin{document}",
			"\\maketitle",
			"",
			"\\section*{Introduction}",
			"",
			"\\end{document}",
		}
	end

	-- Read template file
	local template_content = vim.fn.readfile(template_file)
	if not template_content then
		vim.notify("Failed to read template file: " .. template_file, vim.log.levels.ERROR)
		return nil
	end

	-- Process variables in template
	local processed_content = {}
	local current_date = vim.fn.strftime("%Y-%m-%d")

	-- Set up variable replacements
	local replacements = {
		["{{author}}"] = variables.author,
		["{{date}}"] = current_date,
		["{{filename}}"] = variables.filename,
		["{{title}}"] = variables.title or variables.filename,
	}

	for _, line in ipairs(template_content) do
		local processed_line = line
		for pattern, replacement in pairs(replacements) do
			processed_line = processed_line:gsub(pattern:gsub("[%[%]%(%)%.%*%+%-%?%^%$]", "%%%1"), replacement)
		end
		table.insert(processed_content, processed_line)
	end

	return processed_content
end

-- Create the LaTeX file with template content
local function create_latex_file(filename, author, template_file)
	local tex_filename = filename .. ".tex"

	-- Process template with variables
	local content = process_template(template_file, {
		filename = filename,
		author = author,
		title = filename, -- Default title to filename, could be made configurable
	})

	if not content then
		return nil
	end

	-- Check if file already exists
	if file_exists(tex_filename) then
		vim.ui.select({ "overwrite", "cancel" }, {
			prompt = string.format("File '%s' already exists. What would you like to do?", tex_filename),
		}, function(choice)
			if choice == "overwrite" then
				vim.fn.writefile(content, tex_filename)
				-- File overwritten silently
				vim.cmd("edit " .. tex_filename)
			else
				-- Operation cancelled silently
			end
		end)
	else
		vim.fn.writefile(content, tex_filename)
		-- File created silently
		vim.cmd("edit " .. tex_filename)
	end

	return tex_filename
end

-- Create the project configuration file
local function create_project_config(main_file)
	local config = { main = main_file }
	local config_content = vim.json.encode(config)
	vim.fn.writefile({ config_content }, ".texproject.json")

	-- Clear cache for this directory
	local config_path = vim.fn.resolve(vim.fn.getcwd() .. "/.texproject.json")
	project_cache[config_path] = config

	-- Project config created silently
end

-- Create output directory
local function create_output_directory(project_dir)
	local out_dir = project_dir .. "/out"
	if not file_exists(out_dir) then
		local success = vim.fn.mkdir(out_dir, "p")
		if success == 1 then
			-- Output directory created silently
		else
			vim.notify("Failed to create output directory", vim.log.levels.ERROR)
			return false
		end
	end
	return true
end

-- Check if a LaTeX file uses biblatex
local function uses_biblatex(tex_file_path)
	if not file_exists(tex_file_path) then
		return false
	end

	local content = vim.fn.readfile(tex_file_path)
	for _, line in ipairs(content) do
		if line:match("\\usepackage.*{biblatex}") then
			return true
		end
	end
	return false
end

-- Compile LaTeX file asynchronously with output directory
local function compile_latex(main_file)
	if not main_file then
		return
	end

	-- Determine the project directory from the current buffer or config
	local config = load_project_config()
	local project_dir
	local tex_file_path

	if config and config.main then
		-- If we have a config, find the directory containing the main file
		project_dir = vim.fn.getcwd()
		-- Search for the project directory containing .texproject.json
		local config_file = vim.fn.findfile(".texproject.json", ".;")
		if config_file ~= "" then
			project_dir = vim.fn.fnamemodify(config_file, ":h")
		end
		tex_file_path = project_dir .. "/" .. main_file
	else
		-- No config, use the directory of the current buffer
		local current_file = vim.fn.expand("%:p")
		project_dir = vim.fn.fnamemodify(current_file, ":h")
		tex_file_path = current_file
		main_file = vim.fn.fnamemodify(current_file, ":t")
	end

	-- Create output directory in the project directory
	local out_dir = project_dir .. "/out"
	if not file_exists(out_dir) then
		create_output_directory(project_dir)
	end

	-- Check if we're using biblatex
	local has_biblatex = uses_biblatex(tex_file_path)

	-- Check if latexmk is available
	local use_latexmk = vim.fn.executable("latexmk") == 1

	if has_biblatex then
		-- For biblatex documents, use the reliable no-output-directory approach
		compile_with_biblatex(main_file, project_dir)
	elseif use_latexmk then
		-- For non-biblatex documents, use normal latexmk with output directory
		local cmd = "latexmk"
		local args = { "-pdf", "-output-directory=out", main_file }

		vim.notify(
			string.format("Compiling %s → %s/out/", main_file, vim.fn.fnamemodify(project_dir, ":t")),
			vim.log.levels.INFO
		)

		vim.fn.jobstart({ cmd, unpack(args) }, {
			cwd = project_dir,
			on_exit = function(_, exit_code)
				if exit_code == 0 then
					local pdf_name = main_file:gsub("%.tex$", ".pdf")
					vim.notify(
						string.format("✓ Successfully compiled %s → out/%s", main_file, pdf_name),
						vim.log.levels.INFO
					)
				else
					vim.notify(
						string.format("✗ Failed to compile %s (exit code: %d)", main_file, exit_code),
						vim.log.levels.ERROR
					)
				end
			end,
			on_stderr = function(_, data)
				if data and #data > 0 then
					local error_msg = table.concat(data, "\n")
					if error_msg:match("%S") then -- Only show if not just whitespace
						vim.notify(
							"LaTeX compilation warnings detected. Check output for details.",
							vim.log.levels.WARN
						)
					end
				end
			end,
		})
	else
		-- Manual compilation process (no latexmk available)
		local cmd = "pdflatex"
		local args = { "-output-directory=out", "-interaction=nonstopmode", main_file }

		vim.notify(
			string.format("Compiling %s → %s/out/ (manual mode)", main_file, vim.fn.fnamemodify(project_dir, ":t")),
			vim.log.levels.INFO
		)

		vim.fn.jobstart({ cmd, unpack(args) }, {
			cwd = project_dir,
			on_exit = function(_, exit_code)
				if exit_code == 0 then
					local pdf_name = main_file:gsub("%.tex$", ".pdf")
					vim.notify(
						string.format("✓ Successfully compiled %s → out/%s", main_file, pdf_name),
						vim.log.levels.INFO
					)
					if has_biblatex then
						vim.notify(
							"Note: Bibliography may not be processed without latexmk. Install latexmk for full biblatex support.",
							vim.log.levels.INFO
						)
					end
				else
					vim.notify(
						string.format("✗ Failed to compile %s (exit code: %d)", main_file, exit_code),
						vim.log.levels.ERROR
					)
				end
			end,
			on_stderr = function(_, data)
				if data and #data > 0 then
					local error_msg = table.concat(data, "\n")
					if error_msg:match("%S") then -- Only show if not just whitespace
						vim.notify(
							"LaTeX compilation warnings detected. Check output for details.",
							vim.log.levels.WARN
						)
					end
				end
			end,
		})
	end
end

-- Compile LaTeX with biblatex (reliable approach - no output directories)
local function compile_with_biblatex(main_file, project_dir)
	local base_name = main_file:gsub("%.tex$", "")

	vim.notify(
		"Compiling " .. main_file .. " with biblatex (no output directory for compatibility)",
		vim.log.levels.INFO
	)

	-- Create out directory if it doesn't exist
	local out_dir = project_dir .. "/out"
	if not file_exists(out_dir) then
		vim.fn.mkdir(out_dir, "p")
	end

	-- Use latexmk without output directory for biblatex compatibility
	local biber_cmd = get_biber_path()
	local cmd = "latexmk"
	local args = {
		"-pdf",
		"-bibtex",
		"-bibtex-cond",
		"-e",
		"$biber = '" .. biber_cmd .. "'", -- Tell latexmk where biber is
		main_file,
	}

	vim.fn.jobstart({ cmd, unpack(args) }, {
		cwd = project_dir,
		on_exit = function(_, exit_code)
			if exit_code == 0 then
				local pdf_name = main_file:gsub("%.tex$", ".pdf")
				-- Move PDF to out directory
				local source_pdf = project_dir .. "/" .. pdf_name
				local dest_pdf = project_dir .. "/out/" .. pdf_name

				if file_exists(source_pdf) then
					-- Copy PDF to out directory
					local ok, err = pcall(function()
						local content = vim.fn.readfile(source_pdf, "b")
						vim.fn.writefile(content, dest_pdf, "b")
					end)

					if ok then
						vim.notify(
							string.format("✓ Successfully compiled %s with biblatex → out/%s", main_file, pdf_name),
							vim.log.levels.INFO
						)
						-- Clean up auxiliary files in project root
						vim.notify("Cleaning up auxiliary files...", vim.log.levels.INFO)
						local cleanup_cmd = "latexmk"
						local cleanup_args = { "-c", main_file }
						vim.fn.jobstart({ cleanup_cmd, unpack(cleanup_args) }, { cwd = project_dir })
					else
						vim.notify("Compilation succeeded but failed to move PDF to out/", vim.log.levels.WARN)
					end
				else
					vim.notify("Compilation succeeded but PDF not found", vim.log.levels.WARN)
				end
			else
				vim.notify(
					string.format("✗ Failed to compile %s (exit code: %d)", main_file, exit_code),
					vim.log.levels.ERROR
				)
			end
		end,
		on_stderr = function(_, data)
			if data and #data > 0 then
				local error_msg = table.concat(data, "\n")
				if error_msg:match("%S") then
					vim.notify("Compilation warnings detected", vim.log.levels.WARN)
				end
			end
		end,
	})
end

-- Set up VimTeX integration
local function setup_vimtex_integration()
	local group = vim.api.nvim_create_augroup("TexProjectVimTeX", { clear = true })

	vim.api.nvim_create_autocmd("BufEnter", {
		group = group,
		pattern = "*.tex",
		callback = function()
			local config = load_project_config()
			if config and config.main then
				local main_path = vim.fn.resolve(vim.fn.getcwd() .. "/" .. config.main)
				if file_exists(main_path) then
					vim.b.vimtex_main = main_path
				end
			end
		end,
	})
end

-- Set up auto-compilation on save
local function setup_auto_compilation()
	local group = vim.api.nvim_create_augroup("TexProjectAutoCompile", { clear = true })

	vim.api.nvim_create_autocmd("BufWritePost", {
		group = group,
		pattern = "*.tex",
		callback = function()
			local config = load_project_config()
			if config and config.main then
				compile_latex(config.main)
			else
				-- If no project config, try to compile the current file
				local current_file = vim.fn.expand("%:t")
				compile_latex(current_file)
			end
		end,
	})
end

-- Recursively get all subdirectories
local function get_all_subdirectories(base_path, current_path, max_depth)
	max_depth = max_depth or 3 -- Limit depth to prevent excessive scanning
	local dirs = {}
	local full_path = base_path .. (current_path ~= "" and "/" .. current_path or "")

	local handle = vim.loop.fs_scandir(full_path)
	if handle and max_depth > 0 then
		while true do
			local name, type = vim.loop.fs_scandir_next(handle)
			if not name then
				break
			end
			if type == "directory" and not name:match("^%.") then -- Exclude hidden dirs
				local relative_path = current_path ~= "" and (current_path .. "/" .. name) or name
				table.insert(dirs, relative_path)

				-- Recursively get subdirectories
				local sub_dirs = get_all_subdirectories(base_path, relative_path, max_depth - 1)
				for _, sub_dir in ipairs(sub_dirs) do
					table.insert(dirs, sub_dir)
				end
			end
		end
	end

	return dirs
end

-- Get subdirectories for selection with multi-level support
local function get_subdirectories()
	local dirs = { "." } -- Always include current directory
	local base_path = vim.fn.getcwd()
	local sub_dirs = get_all_subdirectories(base_path, "", 3)

	for _, dir in ipairs(sub_dirs) do
		table.insert(dirs, dir)
	end

	table.sort(dirs, function(a, b)
		if a == "." then
			return true
		end
		if b == "." then
			return false
		end
		return a < b
	end)

	return dirs
end

-- Main command implementation
local function tex_project_new()
	local templates = get_available_templates()

	-- Prompt for template selection
	vim.ui.select(templates, {
		prompt = "Select template:",
		format_item = function(item)
			return item.name
		end,
	}, function(selected_template)
		if not selected_template then
			-- Template selection cancelled silently
			return
		end

		local subdirs = get_subdirectories()

		-- Prompt for directory selection
		vim.ui.select(subdirs, {
			prompt = "Select directory for TeX project:",
			format_item = function(item)
				return item == "." and ". (current directory)" or item
			end,
		}, function(selected_dir)
			if not selected_dir then
				-- Project creation cancelled silently
				return
			end

			-- Store original directory and change to selected directory
			local original_dir = vim.fn.getcwd()
			local target_dir = selected_dir == "." and original_dir or (original_dir .. "/" .. selected_dir)

			if not file_exists(target_dir) then
				vim.notify(string.format("Directory '%s' does not exist", target_dir), vim.log.levels.ERROR)
				return
			end

			vim.cmd("cd " .. target_dir)

			-- Prompt for filename
			vim.ui.input({
				prompt = "Filename (default: main): ",
				default = "main",
			}, function(filename)
				if not filename or filename == "" then
					filename = "main"
				end

				-- Remove .tex extension if provided
				filename = filename:gsub("%.tex$", "")

				-- Prompt for author
				vim.ui.input({
					prompt = "Author: ",
				}, function(author)
					if not author or author == "" then
						author = "Author Name"
					end

					-- Create all the files in the selected directory
					local tex_filename = create_latex_file(filename, author, selected_template.file)
					if tex_filename then
						create_project_config(tex_filename)
						create_output_directory(target_dir)
						vim.notify(
							string.format(
								"TeX project created in '%s' using template '%s' (output: out/)",
								target_dir,
								selected_template.name
							),
							vim.log.levels.INFO
						)
					end

					-- Return to original directory
					vim.cmd("cd " .. original_dir)
				end)
			end)
		end)
	end)
end

-- Get the full path to Biber executable
local function get_biber_path()
	-- Check common TinyTeX locations
	local tinytex_paths = {
		"/Users/" .. vim.fn.expand("$USER") .. "/Library/TinyTeX/bin/universal-darwin/biber",
		"/Users/" .. vim.fn.expand("$USER") .. "/Library/TinyTeX/bin/x86_64-darwin/biber",
	}

	for _, path in ipairs(tinytex_paths) do
		if file_exists(path) then
			return path
		end
	end

	-- Fallback to system PATH
	return "biber"
end

-- Copy bibliography file to output directory for Biber
local function ensure_bib_file_access(project_dir, base_name)
	-- Check if we have a .bib file to copy
	local bib_source = project_dir .. "/references/references.bib"
	local bib_dest = project_dir .. "/out/references.bib"

	if file_exists(bib_source) then
		-- Copy the .bib file to output directory
		local content = vim.fn.readfile(bib_source)
		vim.fn.writefile(content, bib_dest)
		return true
	end
	return false
end

-- Test Biber manually for debugging (simple approach)
local function test_biber_manual()
	local config = load_project_config()
	local project_dir = vim.fn.getcwd()
	local main_file = "main.tex"

	if config and config.main then
		main_file = config.main
	end

	local base_name = main_file:gsub("%.tex$", "")
	local biber_cmd = get_biber_path()

	vim.notify("Testing Biber (simple approach - no output directories)...", vim.log.levels.INFO)

	-- Check if .bcf file exists in project root (new approach)
	local bcf_path = project_dir .. "/" .. base_name .. ".bcf"
	if not file_exists(bcf_path) then
		vim.notify(
			"Error: " .. bcf_path .. " not found. Run pdflatex without output directory first.",
			vim.log.levels.ERROR
		)
		vim.notify(
			"For biblatex documents, compilation happens in project root for compatibility.",
			vim.log.levels.INFO
		)
		return
	end

	-- Check if bibliography file exists
	local bib_path = project_dir .. "/references/references.bib"
	if not file_exists(bib_path) then
		vim.notify("Warning: " .. bib_path .. " not found", vim.log.levels.WARN)
	end

	-- Run Biber from project directory (simple)
	vim.fn.jobstart({ biber_cmd, base_name }, {
		cwd = project_dir,
		on_stdout = function(_, data)
			if data and #data > 0 then
				local output = table.concat(data, "\n")
				if output:match("%S") then
					vim.notify("Biber: " .. output, vim.log.levels.INFO)
				end
			end
		end,
		on_stderr = function(_, data)
			if data and #data > 0 then
				local error_output = table.concat(data, "\n")
				if error_output:match("%S") then
					vim.notify("Biber error: " .. error_output, vim.log.levels.ERROR)
				end
			end
		end,
		on_exit = function(_, exit_code)
			if exit_code == 0 then
				vim.notify("✓ Biber successful! Bibliography should now work.", vim.log.levels.INFO)
				-- Check if .bbl file was created
				local bbl_path = project_dir .. "/" .. base_name .. ".bbl"
				if file_exists(bbl_path) then
					vim.notify("✓ Generated " .. base_name .. ".bbl file in project root", vim.log.levels.INFO)
				end
			else
				vim.notify("✗ Biber failed (exit code: " .. exit_code .. ")", vim.log.levels.ERROR)
			end
		end,
	})
end

-- Setup function to initialize the module
function M.setup()
	-- Create the user command
	vim.api.nvim_create_user_command("TProj", tex_project_new, {
		desc = "Create a new TeX project with templates and configuration",
	})

	-- Create debugging command
	vim.api.nvim_create_user_command("TProjTestBiber", test_biber_manual, {
		desc = "Test Biber manually for debugging bibliography issues",
	})

	-- Set up auto-compilation
	setup_auto_compilation()

	-- Set up VimTeX integration if available
	local has_vimtex = pcall(require, "vimtex")
	if has_vimtex then
		setup_vimtex_integration()
	end
end

return M

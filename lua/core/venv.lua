local M = {}

-- Cache for detected virtual environments
local venv_cache = {}

--- Detect if we're in a Python virtual environment
--- @return string|nil python_path The path to the Python executable in the venv
local function detect_venv()
	local cwd = vim.fn.getcwd()

	-- Check cache first
	if venv_cache[cwd] then
		return venv_cache[cwd]
	end

	local possible_venv_paths = {
		-- Standard venv/virtualenv locations
		cwd .. "/venv/bin/python",
		cwd .. "/venv/Scripts/python.exe", -- Windows
		cwd .. "/.venv/bin/python",
		cwd .. "/.venv/Scripts/python.exe", -- Windows
		-- Poetry
		cwd .. "/.venv/bin/python",
		-- Conda environments (check CONDA_DEFAULT_ENV)
		vim.env.CONDA_PREFIX and vim.env.CONDA_PREFIX .. "/bin/python",
	}

	-- Check for pipenv
	local pipenv_result = vim.fn.system("cd " .. vim.fn.shellescape(cwd) .. " && pipenv --venv 2>/dev/null")
	if vim.v.shell_error == 0 and pipenv_result and pipenv_result ~= "" then
		local pipenv_path = vim.trim(pipenv_result)
		table.insert(possible_venv_paths, pipenv_path .. "/bin/python")
		table.insert(possible_venv_paths, pipenv_path .. "/Scripts/python.exe") -- Windows
	end

	-- Check for poetry
	local poetry_result = vim.fn.system("cd " .. vim.fn.shellescape(cwd) .. " && poetry env info --path 2>/dev/null")
	if vim.v.shell_error == 0 and poetry_result and poetry_result ~= "" then
		local poetry_path = vim.trim(poetry_result)
		table.insert(possible_venv_paths, poetry_path .. "/bin/python")
		table.insert(possible_venv_paths, poetry_path .. "/Scripts/python.exe") -- Windows
	end

	-- Find the first existing Python executable
	for _, python_path in ipairs(possible_venv_paths) do
		if python_path and vim.fn.executable(python_path) == 1 then
			venv_cache[cwd] = python_path
			return python_path
		end
	end

	-- No venv found
	venv_cache[cwd] = nil
	return nil
end

--- Get the virtual environment path from Python executable path
--- @param python_path string
--- @return string|nil venv_path
local function get_venv_path(python_path)
	if not python_path then
		return nil
	end

	-- Extract venv path from python executable path
	local venv_path = python_path:match("(.+)/bin/python") or python_path:match("(.+)\\Scripts\\python%.exe")
	return venv_path
end

--- Activate virtual environment for current working directory
--- @param python_path string|nil Optional python path, will detect if not provided
--- @return boolean success
function M.activate_venv(python_path)
	python_path = python_path or detect_venv()

	if not python_path then
		return false
	end

	local venv_path = get_venv_path(python_path)
	if not venv_path then
		return false
	end

	-- Set environment variables
	vim.env.VIRTUAL_ENV = venv_path
	vim.env.PYTHON_PATH = python_path

	-- Update PATH to include venv/bin or venv/Scripts
	local bin_path = python_path:match("(.+)/python") or python_path:match("(.+)\\python%.exe")
	if bin_path then
		local current_path = vim.env.PATH or ""
		if not current_path:find(vim.pesc(bin_path), 1, true) then
			vim.env.PATH = bin_path .. (vim.fn.has("win32") == 1 and ";" or ":") .. current_path
		end
	end

	-- Note: Notification removed per user request - venv info will be shown in statusline

	-- Trigger LspRestart for Python servers to pick up new environment
	vim.schedule(function()
		local clients = vim.lsp.get_clients({ name = "pyright" })
		for _, client in ipairs(clients) do
			vim.cmd("LspRestart " .. client.id)
		end
	end)

	return true
end

--- Get current virtual environment info
--- @return table|nil venv_info
function M.get_venv_info()
	local python_path = detect_venv()
	if not python_path then
		return nil
	end

	local venv_path = get_venv_path(python_path)
	return {
		python_path = python_path,
		venv_path = venv_path,
		is_active = vim.env.VIRTUAL_ENV == venv_path,
	}
end

--- Auto-detect and activate venv for current directory
function M.auto_activate()
	local python_path = detect_venv()
	if python_path then
		M.activate_venv(python_path)
	end
end

--- Clear venv cache (useful when switching directories)
function M.clear_cache()
	venv_cache = {}
end

--- Setup autocommands for venv detection
function M.setup()
	local group = vim.api.nvim_create_augroup("VenvDetection", { clear = true })

	-- Auto-activate venv when entering a directory
	vim.api.nvim_create_autocmd("DirChanged", {
		group = group,
		callback = function()
			M.clear_cache()
			-- Small delay to ensure directory change is complete
			vim.defer_fn(function()
				M.auto_activate()
			end, 100)
		end,
	})

	-- Auto-activate venv on VimEnter
	vim.api.nvim_create_autocmd("VimEnter", {
		group = group,
		callback = function()
			-- Delay to ensure everything is loaded
			vim.defer_fn(function()
				M.auto_activate()
			end, 500)
		end,
	})

	-- Create user commands
	vim.api.nvim_create_user_command("VenvActivate", function()
		if not M.activate_venv() then
			vim.notify("No Python virtual environment found in current directory", vim.log.levels.WARN)
		end
	end, { desc = "Activate Python virtual environment" })

	vim.api.nvim_create_user_command("VenvInfo", function()
		local info = M.get_venv_info()
		if info then
			vim.notify(
				string.format("Python: %s\nVenv: %s\nActive: %s", info.python_path, info.venv_path, info.is_active),
				vim.log.levels.INFO
			)
		else
			vim.notify("No virtual environment detected", vim.log.levels.INFO)
		end
	end, { desc = "Show virtual environment info" })
end

return M

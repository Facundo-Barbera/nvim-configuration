--- Module loading utilities
--- Safe module loading and management functions

local M = {}

--- Safely require a module with error handling
--- @param module_name string The module name to require
--- @param silent boolean Whether to suppress error notifications (default: false)
--- @return boolean, any success status and module or error message
function M.safe_require(module_name, silent)
	local ok, result = pcall(require, module_name)

	if not ok and not silent then
		vim.notify(
			string.format("Failed to load module '%s': %s", module_name, result),
			vim.log.levels.WARN
		)
	end

	return ok, result
end

--- Load a module and call its setup function if it exists
--- @param module_name string The module name to require and setup
--- @param setup_args table Optional arguments to pass to setup function
--- @return boolean success true if module loaded and setup successfully
function M.load_and_setup(module_name, setup_args)
	local ok, module = M.safe_require(module_name)

	if not ok then
		return false
	end

	-- If the module has a setup function, call it
	if type(module) == "table" and type(module.setup) == "function" then
		local setup_ok, setup_err = pcall(module.setup, setup_args)
		if not setup_ok then
			vim.notify(
				string.format("Failed to setup module '%s': %s", module_name, setup_err),
				vim.log.levels.ERROR
			)
			return false
		end
	end

	return true
end

--- Check if a module is available without loading it
--- @param module_name string The module name to check
--- @return boolean available true if module can be loaded
function M.is_available(module_name)
	local ok, _ = pcall(require, module_name)
	return ok
end

--- Load multiple modules with error handling
--- @param modules table List of module names to load
--- @param silent boolean Whether to suppress error notifications (default: false)
--- @return table results Table with module names as keys and {success, module/error} as values
function M.load_modules(modules, silent)
	local results = {}

	for _, module_name in ipairs(modules) do
		local ok, result = M.safe_require(module_name, silent)
		results[module_name] = { success = ok, result = result }
	end

	return results
end

--- Load a list of core modules in order, calling setup if available
--- @param modules table List of module names to load and setup
--- @return boolean all_loaded true if all modules loaded successfully
function M.load_core_modules(modules)
	local all_success = true

	for _, module_name in ipairs(modules) do
		local success = M.load_and_setup(module_name)
		if not success then
			all_success = false
		end
	end

	return all_success
end

return M
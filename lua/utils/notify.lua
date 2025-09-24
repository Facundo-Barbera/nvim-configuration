--- Notification utilities
--- Consistent notification handling throughout the configuration

local M = {}

--- Show an info notification
--- @param message string The message to display
--- @param title string Optional title prefix
function M.info(message, title)
	local msg = title and string.format("[%s] %s", title, message) or message
	vim.notify(msg, vim.log.levels.INFO)
end

--- Show a warning notification
--- @param message string The message to display
--- @param title string Optional title prefix
function M.warn(message, title)
	local msg = title and string.format("[%s] %s", title, message) or message
	vim.notify(msg, vim.log.levels.WARN)
end

--- Show an error notification
--- @param message string The message to display
--- @param title string Optional title prefix
function M.error(message, title)
	local msg = title and string.format("[%s] %s", title, message) or message
	vim.notify(msg, vim.log.levels.ERROR)
end

--- Show a debug notification (only if debug mode is enabled)
--- @param message string The message to display
--- @param title string Optional title prefix
function M.debug(message, title)
	-- Only show debug messages if explicitly enabled
	if vim.g.nvim_config_debug then
		local msg = title and string.format("[DEBUG][%s] %s", title, message) or string.format("[DEBUG] %s", message)
		vim.notify(msg, vim.log.levels.DEBUG)
	end
end

--- Show a success notification with checkmark
--- @param message string The message to display
--- @param title string Optional title prefix
function M.success(message, title)
	local msg = title and string.format("✓ [%s] %s", title, message) or string.format("✓ %s", message)
	vim.notify(msg, vim.log.levels.INFO)
end

--- Show a failure notification with X mark
--- @param message string The message to display
--- @param title string Optional title prefix
function M.fail(message, title)
	local msg = title and string.format("✗ [%s] %s", title, message) or string.format("✗ %s", message)
	vim.notify(msg, vim.log.levels.ERROR)
end

--- Notify about compilation/build results
--- @param success boolean Whether the operation succeeded
--- @param message string The message to display
--- @param title string Optional title prefix
function M.build_result(success, message, title)
	if success then
		M.success(message, title)
	else
		M.fail(message, title)
	end
end

--- Show notifications for command execution results
--- @param cmd string The command that was executed
--- @param code number Exit code
--- @param stdout string Standard output
--- @param stderr string Standard error
function M.command_result(cmd, code, stdout, stderr)
	if code == 0 then
		if stdout and stdout ~= "" then
			M.success(string.format("Command '%s' completed successfully", cmd))
		end
	else
		local error_msg = stderr and stderr ~= "" and stderr or "Unknown error"
		M.error(string.format("Command '%s' failed: %s", cmd, error_msg))
	end
end

return M
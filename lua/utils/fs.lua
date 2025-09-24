--- File system utilities
--- Common file system operations used throughout the configuration

local M = {}

--- Check if a file or directory exists
--- @param path string The path to check
--- @return boolean true if the file exists, false otherwise
function M.file_exists(path)
	local f = io.open(path, "r")
	if f then
		f:close()
		return true
	else
		return false
	end
end

--- Check if a path is a directory
--- @param path string The path to check
--- @return boolean true if it's a directory, false otherwise
function M.is_directory(path)
	local stat = (vim.uv or vim.loop).fs_stat(path)
	return stat and stat.type == "directory"
end

--- Create a directory if it doesn't exist
--- @param path string The directory path to create
--- @param parents boolean Whether to create parent directories (default: true)
--- @return boolean success true if directory was created or already exists
function M.ensure_directory(path, parents)
	if parents == nil then parents = true end

	if M.file_exists(path) then
		return true
	end

	local success = vim.fn.mkdir(path, parents and "p" or "")
	return success == 1
end

--- Get the directory part of a file path
--- @param filepath string Full file path
--- @return string The directory path
function M.dirname(filepath)
	return vim.fn.fnamemodify(filepath, ":h")
end

--- Get the filename part of a file path
--- @param filepath string Full file path
--- @return string The filename
function M.basename(filepath)
	return vim.fn.fnamemodify(filepath, ":t")
end

--- Get the file extension
--- @param filepath string Full file path
--- @return string The file extension (including the dot)
function M.extension(filepath)
	return vim.fn.fnamemodify(filepath, ":e")
end

--- Join path components
--- @param ... string Path components to join
--- @return string The joined path
function M.join(...)
	local parts = {...}
	return table.concat(parts, "/"):gsub("//+", "/")
end

return M
-- Core Neovim configuration loader
-- This module loads all core Neovim settings and configurations

local M = {}

-- Load core modules in order
local core_modules = {
	"core.options", -- Vim options and settings
	"core.keymaps", -- Basic key mappings
	"core.commands", -- Custom commands and autocommands
	"core.spell", -- Enhanced spell checking
}

function M.setup()
	-- Load each core module
	for _, module in ipairs(core_modules) do
		local ok, err = pcall(require, module)
		if not ok then
			vim.notify(string.format("Failed to load core module '%s': %s", module, err), vim.log.levels.ERROR)
		end
	end
end

return M

-- Core Neovim configuration loader
-- This module loads all core Neovim settings and configurations

local M = {}

-- Load core modules in order
local core_modules = {
	"core.options", -- Vim options and settings
	"core.keymaps", -- Basic key mappings
	"core.commands", -- Custom commands and autocommands
	"core.spell", -- Enhanced spell checking
	"core.venv", -- Python virtual environment detection
	"core.buffer_manager", -- Smart buffer management
}

function M.setup()
	-- Load each core module
	for _, module in ipairs(core_modules) do
		local ok, loaded_module = pcall(require, module)
		if ok then
			-- If the module has a setup function, call it
			if type(loaded_module) == "table" and type(loaded_module.setup) == "function" then
				local setup_ok, setup_err = pcall(loaded_module.setup)
				if not setup_ok then
					vim.notify(
						string.format("Failed to setup module '%s': %s", module, setup_err),
						vim.log.levels.ERROR
					)
				end
			end
		else
			vim.notify(
				string.format("Failed to load core module '%s': %s", module, loaded_module),
				vim.log.levels.ERROR
			)
		end
	end
end

return M

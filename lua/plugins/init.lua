-- Simplified plugin management system
-- Returns all plugins in a flat structure for Lazy.nvim

-- For now, let's use the original approach but with better organization
-- Users can navigate to specific categories using the new directory structure

return {
	-- Import all plugins using the old pattern but organized files
	{ import = "plugins.editor" },
	{ import = "plugins.navigation" },
	{ import = "plugins.ui" },
	{ import = "plugins.lsp" },
	{ import = "plugins.git" },
	{ import = "plugins.coding" },
	{ import = "plugins.languages" },
}

-- Dooing: The minimalist to-do list for Neovim
-- Simple task management directly within your editor

return {
	"atiladefreitas/dooing",
	config = function()
		require("dooing").setup({
			-- Custom configuration options can go here
			-- The plugin works out of the box with sensible defaults
		})
	end,
	-- Load the plugin immediately for task management
	lazy = false,
}
-- UI decorations and visual enhancements
-- Cursor effects, utilities, etc.

return {
	{
		"sphamba/smear-cursor.nvim",
		opts = {
			cursor_color = "#c6d0f5",
			normal_bg = "#303446",
			smear_between_buffers = true,
			smear_between_neighbor_lines = true,
			use_floating_windows = true,
			legacy_computing_symbols_support = false,
		},
	},
}

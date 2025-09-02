return {
	"MeanderingProgrammer/render-markdown.nvim",
	dependencies = { "nvim-treesitter/nvim-treesitter" },
	opts = {},

	config = function()
		require("render-markdown").setup({
			render_modes = true,
		})
	end,
}

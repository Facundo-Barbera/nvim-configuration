return {
	{
		"quarto-dev/quarto-nvim",
		dependencies = {
			"jmbuhr/otter.nvim",
			"nvim-treesitter/nvim-treesitter",
		},
		ft = { "quarto" },
		config = function()
			require("quarto").setup({
				lspFeatures = {
					enabled = true,
					completion = {
						enabled = true,
					},
				},
			})
		end,
	},
}

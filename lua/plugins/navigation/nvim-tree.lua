-- In your nvim-tree.lua config
return {
	"nvim-tree/nvim-tree.lua",
	version = "*",
	lazy = false,
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
	config = function()
		require("nvim-tree").setup({
			disable_netrw = true,
			hijack_netrw = true,
			view = {
				width = 30,
				side = "left",
				preserve_window_proportions = true,
				number = false,
				relativenumber = false,
				signcolumn = "no",
			},
			renderer = {
				icons = {
					show = {
						file = true,
						folder = true,
						folder_arrow = true,
						git = true,
					},
				},
			},
			actions = {
				open_file = {
					quit_on_open = false, -- Keep tree open when opening files
					resize_window = true,
					window_picker = {
						enable = true,
						chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890",
						exclude = {
							filetype = { "notify", "packer", "qf", "diff", "fugitive", "fugitiveblame", "NvimTree" },
							buftype = { "nofile", "terminal", "help" },
						},
					},
				},
			},
			filters = {
				dotfiles = false,
				custom = {
					"^.git$",
					-- macOS system files
					"^.DS_Store$",
					"^.AppleDouble$",
					"^.LSOverride$",
					-- Windows system files
					"^Thumbs.db$",
					"^ehthumbs.db$",
					"^Desktop.ini$",
					-- Linux system files
					"^.directory$",
				},
			},
			git = {
				enable = true,
				ignore = false,
			},
			update_focused_file = {
				enable = true,
				update_root = false,
				ignore_list = {},
			},
		})

		-- Enhanced keymaps
		vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Toggle file explorer" })
	end,
}

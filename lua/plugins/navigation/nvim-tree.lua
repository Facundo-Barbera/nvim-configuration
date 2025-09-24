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
			hijack_unnamed_buffer_when_opening = false,
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
				remove_file = {
					close_window = false,
				},
				change_dir = {
					enable = true,
					global = false,
					restrict_above_cwd = false,
				},
			},
			notify = {
				threshold = vim.log.levels.ERROR, -- Only show errors, suppress all other messages
				absolute_path = false,
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
			filesystem_watchers = {
				enable = true,
				debounce_delay = 50,
				ignore_dirs = {},
			},
			system_open = {
				cmd = nil,
				args = {},
			},
			diagnostics = {
				enable = false,
			},
			modified = {
				enable = false,
			},
		})

		-- Enhanced keymaps
		vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Toggle file explorer" })

	end,
}

return {
	name = "r_language_server",
	manual = true, -- Use system R, don't install via Mason
	config = {
		settings = {
			r = {
				lsp = {
					rich_documentation = false,
				},
			},
		},
	},
}

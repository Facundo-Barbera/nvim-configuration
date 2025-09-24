return {
	name = "pyright",
	config = {
		before_init = function(_, config)
			-- Auto-detect and use virtual environment Python interpreter
			local venv = require("core.venv")
			local venv_info = venv.get_venv_info()

			if venv_info and venv_info.python_path then
				-- Set the Python path for Pyright to use the venv Python
				config.settings = config.settings or {}
				config.settings.python = config.settings.python or {}
				config.settings.python.pythonPath = venv_info.python_path
			end
		end,
		settings = {
			python = {
				analysis = {
					typeCheckingMode = "basic",
					autoSearchPaths = true,
					useLibraryCodeForTypes = true,
					autoImportCompletions = true,
					-- Disable specific diagnostics that are too noisy
					diagnosticSeverityOverrides = {
						reportUnknownVariableType = "none",
						reportUnknownMemberType = "none",
						reportUnknownParameterType = "none",
						reportUnknownArgumentType = "none",
						reportGeneralTypeIssues = "warning",
						reportOptionalMemberAccess = "warning",
						reportOptionalSubscript = "warning",
						reportPrivateImportUsage = "warning",
					},
				},
			},
		},
	},
}

return {
    {
        "R-nvim/R.nvim",
        ft = { "r", "rmd" },
        config = function()
            require("r").setup({
                R_args = {"--quiet", "--no-save"},
                min_editor_width = 72,
                rconsole_width = 78,
                disable_cmds = {
                    "RClearConsole",
                    "RCustomStart",
                },
            })
        end,
    },
}

return {
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter.configs").setup({
                ensure_installed = {
                    "r",
                    "markdown", 
                    "rnoweb",
                    "yaml",
                    "lua",
                    "python",
                    "javascript",
                    "typescript",
                    -- Add other parsers you need
                },
                highlight = {
                    enable = true,
                },
                indent = {
                    enable = true,
                },
            })
        end,
    },
}

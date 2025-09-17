-- Language checking integration
-- Combines built-in spell checker with LTeX LSP for comprehensive language support

return {
    -- Spell checking completion source for nvim-cmp
    {
        "f3fora/cmp-spell",
        ft = { "markdown", "text", "gitcommit", "rst", "tex", "typst" },
        config = function()
            -- Add spell source to existing nvim-cmp config
            local ok, cmp = pcall(require, "cmp")
            if ok then
                local config = cmp.get_config()
                local sources = config.sources or {}

                -- Add spell source with lower priority
                table.insert(sources, {
                    name = "spell",
                    option = {
                        keep_all_entries = false,
                        enable_in_context = function()
                            return require("cmp.config.context").in_treesitter_capture("spell")
                        end,
                        preselect_correct_word = true,
                    },
                })

                cmp.setup({ sources = sources })
            end
        end,
    },

    -- LTeX language server for advanced grammar/style checking
    {
        "barreiroleo/ltex_extra.nvim",
        ft = { "markdown", "text", "gitcommit", "rst", "tex", "typst" },
        dependencies = { "neovim/nvim-lspconfig" },
        config = function()
            -- Only setup if LTeX client is available
            local ok, ltex_extra = pcall(require, "ltex_extra")
            if ok then
                ltex_extra.setup({
                    -- Load additional dictionaries
                    load_langs = { "en-US", "es-MX" },
                    -- Initialize the plugin only if ltex is running
                    init_check = false,
                    -- Path to store dictionaries
                    path = vim.fn.expand("~") .. "/.local/share/ltex",
                    -- Log level
                    log_level = "none",
                })
            end
        end,
    },
}
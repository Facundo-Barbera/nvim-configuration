return {
    {
        "mason-org/mason.nvim",
        opts = {},
        config = function()
            require("mason").setup()
        end,
    },
    {
        "mason-org/mason-lspconfig.nvim",
        dependencies = {
            "mason-org/mason.nvim",
            "neovim/nvim-lspconfig",
        },
        config = function()
            local server_names = {}
            local lsp_dir = vim.fn.stdpath("config") .. "/lua/plugins/lsps"

            if vim.fn.isdirectory(lsp_dir) == 1 then
                local files = vim.fn.readdir(lsp_dir)
                for _, file in pairs(files) do
                    if file:match("%.lua$") then
                        local ok, config = pcall(require, "plugins.lsps." .. file:gsub("%.lua$", ""))
                        if ok and config.name then
                            table.insert(server_names, config.name)
                        end
                    end
                end
            end

            require("mason-lspconfig").setup({
                ensure_installed = server_names,
                automatic_installation = true,
            })
        end,
    },
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "mason-org/mason-lspconfig.nvim",
        },
        config = function()
            local lspconfig = require("lspconfig")

            -- Setup default capabilities
            local capabilities = vim.lsp.protocol.make_client_capabilities()
            local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
            if has_cmp then
                capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
            end

            -- Load configs from lsps/ directory
            local config_dir = vim.fn.stdpath("config") .. "/lua/plugins/lsps"

            if vim.fn.isdirectory(config_dir) == 1 then
                local files = vim.fn.readdir(config_dir)
                for _, file in pairs(files) do
                    if file:match("%.lua$") then
                        local ok, server_config = pcall(require, "plugins.lsps." .. file:gsub("%.lua$", ""))

                        if ok and server_config.name then
                            local final_config = vim.tbl_deep_extend("force",
                                { capabilities = capabilities },
                                server_config.config or {}
                            )

                            -- Setup if available (Mason or manual)
                            if server_config.manual or vim.fn.executable(server_config.name) == 1 then
                                lspconfig[server_config.name].setup(final_config)
                            end
                        end
                    end
                end
            end
        end,
    }
}

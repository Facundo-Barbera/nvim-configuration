return {
    {
        "mason-org/mason.nvim",
        opts = {},
        config = function()
            require("mason").setup()
        end,
    },
    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        dependencies = { "mason-org/mason.nvim" },
        config = function()
            require("mason-tool-installer").setup({
                ensure_installed = {
                    -- Formatters
                    "stylua",      -- Lua formatter
                    "black",       -- Python formatter
                    "prettierd",   -- JS/TS/JSON/YAML/MD formatter (faster than prettier)
                    "prettier",    -- Fallback formatter
                },
                auto_update = false,
                run_on_start = true,
            })
        end,
    },
    {
        "mason-org/mason-lspconfig.nvim",
        dependencies = {
            "mason-org/mason.nvim",
            "neovim/nvim-lspconfig",
        },
        config = function()
            local ensure = {}
            local lsp_dir = vim.fn.stdpath("config") .. "/lua/plugins/lsp/servers"

            if vim.fn.isdirectory(lsp_dir) == 1 then
                local files = vim.fn.readdir(lsp_dir)
                for _, file in pairs(files) do
                    if file:match("%.lua$") then
                        local ok, cfg = pcall(require, "plugins.lsp.servers." .. file:gsub("%.lua$", ""))
                        if ok and cfg and cfg.name and not cfg.manual then
                            table.insert(ensure, cfg.name)
                        end
                    end
                end
            end

            require("mason-lspconfig").setup({
                ensure_installed = ensure,
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

            -- Setup enhanced capabilities
            local capabilities = vim.lsp.protocol.make_client_capabilities()

            -- Add nvim-cmp capabilities if available
            local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
            if has_cmp then
                capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
            end

            -- Enable folding capability
            capabilities.textDocument.foldingRange = {
                dynamicRegistration = false,
                lineFoldingOnly = true
            }

            -- Enable snippet support
            capabilities.textDocument.completion.completionItem.snippetSupport = true

            -- Configure diagnostics display
            vim.diagnostic.config({
                virtual_text = {
                    prefix = "●",
                    source = "always",
                },
                float = {
                    source = "always",
                    border = "rounded",
                },
                signs = true,
                underline = true,
                update_in_insert = false,
                severity_sort = true,
            })

            -- LSP keymaps function
            local function setup_lsp_keymaps(bufnr)
                local opts = { buffer = bufnr, silent = true }

                -- Diagnostics
                vim.keymap.set("n", "<leader>de", vim.diagnostic.open_float, vim.tbl_extend("force", opts, { desc = "Show diagnostic error messages" }))
                vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, vim.tbl_extend("force", opts, { desc = "Go to previous diagnostic message" }))
                vim.keymap.set("n", "]d", vim.diagnostic.goto_next, vim.tbl_extend("force", opts, { desc = "Go to next diagnostic message" }))
                vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, vim.tbl_extend("force", opts, { desc = "Open diagnostics list" }))

                -- LSP actions
                vim.keymap.set("n", "gd", vim.lsp.buf.definition, vim.tbl_extend("force", opts, { desc = "Go to definition" }))
                vim.keymap.set("n", "gD", vim.lsp.buf.declaration, vim.tbl_extend("force", opts, { desc = "Go to declaration" }))
                vim.keymap.set("n", "gr", vim.lsp.buf.references, vim.tbl_extend("force", opts, { desc = "Show references" }))
                vim.keymap.set("n", "gi", vim.lsp.buf.implementation, vim.tbl_extend("force", opts, { desc = "Go to implementation" }))
                vim.keymap.set("n", "K", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "Hover Documentation" }))
                vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, vim.tbl_extend("force", opts, { desc = "Signature Documentation" }))
                vim.keymap.set("n", "<leader>D", vim.lsp.buf.type_definition, vim.tbl_extend("force", opts, { desc = "Type definition" }))
                vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, vim.tbl_extend("force", opts, { desc = "Rename" }))
                vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, vim.tbl_extend("force", opts, { desc = "Code actions" }))
                vim.keymap.set("n", "<leader>lf", function()
                    vim.lsp.buf.format({ async = true })
                end, vim.tbl_extend("force", opts, { desc = "Format file" }))
            end

            -- Attach keymaps when LSP connects
            vim.api.nvim_create_autocmd("LspAttach", {
                group = vim.api.nvim_create_augroup("UserLspConfig", {}),
                callback = function(ev)
                    setup_lsp_keymaps(ev.buf)
                end,
            })

            -- Load configs from lsp/servers/ directory with better error handling
            local config_dir = vim.fn.stdpath("config") .. "/lua/plugins/lsp/servers"

            if vim.fn.isdirectory(config_dir) == 1 then
                local files = vim.fn.readdir(config_dir)
                for _, file in pairs(files) do
                    if file:match("%.lua$") then
                        local module_name = "plugins.lsp.servers." .. file:gsub("%.lua$", "")
                        local ok, server_config = pcall(require, module_name)

                        if ok and type(server_config) == "table" and server_config.name then
                            local final_config = vim.tbl_deep_extend("force",
                                { capabilities = capabilities },
                                server_config.config or {}
                            )

                            -- Add common on_attach handler if not specified
                            if not final_config.on_attach then
                                final_config.on_attach = function(client, bufnr)
                                    -- Enable inlay hints if supported
                                    if client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
                                        vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
                                    end
                                end
                            end

                            -- Setup server; Mason handles install. Avoid noisy 'not found' warnings.
                            local setup_ok, setup_err = pcall(function()
                                lspconfig[server_config.name].setup(final_config)
                            end)
                            if not setup_ok then
                                vim.notify(
                                    string.format("Failed to setup LSP server '%s': %s",
                                        server_config.name, setup_err),
                                    vim.log.levels.WARN
                                )
                            end
                        elseif not ok then
                            vim.notify(
                                string.format("Failed to load LSP config '%s': %s", module_name, server_config),
                                vim.log.levels.ERROR
                            )
                        end
                    end
                end
            end
        end,
    }
}

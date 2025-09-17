-- LTeX/LTeX+ Language Server Configuration
-- Provides advanced grammar and style checking via LanguageTool

return {
    name = "ltex",
    config = {
        -- Automatically install via Mason
        manual = false,

        -- Server settings
        settings = {
            ltex = {
                -- Languages to check (prefer LTeX+ format)
                language = "en-US",
                additionalLanguages = { "es-MX" },

                -- Enable checking for specific document types
                enabledRules = {},
                disabledRules = {},

                -- Dictionary settings
                dictionary = {
                    ["en-US"] = {},
                    ["es-MX"] = {},
                },

                -- Disable false positives
                disabledRulesFile = {},
                hiddenFalsePositives = {},

                -- LanguageTool settings
                languageToolHttpServerUri = "",
                languageToolOrg = {
                    username = "",
                    apiKey = "",
                },

                -- Advanced settings
                completionEnabled = true,
                diagnosticSeverity = "information",

                -- Markdown-specific settings
                markdown = {
                    nodes = {
                        -- Don't check code blocks
                        CodeBlock = "ignore",
                        FencedCodeBlock = "ignore",
                        AutoLink = "ignore",
                        Code = "ignore",
                    },
                },

                -- LaTeX-specific settings
                latex = {
                    commands = {
                        ["\\cite{}"] = "ignore",
                        ["\\ref{}"] = "ignore",
                        ["\\label{}"] = "ignore",
                    },
                    environments = {
                        lstlisting = "ignore",
                        verbatim = "ignore",
                    },
                },

                -- Configure checking behavior
                configurationTarget = {
                    dictionary = "workspaceFolderExternalFile",
                    disabledRules = "workspaceFolderExternalFile",
                    hiddenFalsePositives = "workspaceFolderExternalFile",
                },

                -- Set working directory for project-specific configs
                workspaceFolderPath = "",

                -- Logging (set to "severe" in production)
                logLevel = "severe",
            },
        },

        -- File types to attach to
        filetypes = {
            "markdown",
            "text",
            "gitcommit",
            "rst",
            "tex",
            "typst",
            "mail",
            "org",
        },

        -- Custom initialization function
        on_init = function(client, _)
            -- Set workspace folder for project-specific .ltexrc.json support
            if client.config.settings.ltex then
                client.config.settings.ltex.workspaceFolderPath = vim.loop.cwd()
            end
        end,

        -- Custom attach function for additional setup
        on_attach = function(client, bufnr)
            -- Enable inlay hints if supported
            if client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
                vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
            end

            -- Set up buffer-specific keymaps
            local opts = { buffer = bufnr, silent = true }

            -- Quick language switching
            vim.keymap.set("n", "<leader>le", function()
                client.config.settings.ltex.language = "en-US"
                client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
                vim.notify("LTeX language set to English (US)", vim.log.levels.INFO)
            end, vim.tbl_extend("force", opts, { desc = "Set LTeX to English" }))

            vim.keymap.set("n", "<leader>ls", function()
                client.config.settings.ltex.language = "es-MX"
                client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
                vim.notify("LTeX language set to Spanish (Mexico)", vim.log.levels.INFO)
            end, vim.tbl_extend("force", opts, { desc = "Set LTeX to Spanish" }))

            -- Add word to dictionary
            vim.keymap.set("n", "<leader>la", function()
                local word = vim.fn.expand("<cword>")
                local lang = client.config.settings.ltex.language
                local dict = client.config.settings.ltex.dictionary[lang] or {}
                table.insert(dict, word)
                client.config.settings.ltex.dictionary[lang] = dict
                client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
                vim.notify(string.format("Added '%s' to %s dictionary", word, lang), vim.log.levels.INFO)
            end, vim.tbl_extend("force", opts, { desc = "Add word to LTeX dictionary" }))
        end,

        -- Root directory detection
        root_dir = function(fname)
            return require("lspconfig.util").find_git_ancestor(fname)
                or require("lspconfig.util").path.dirname(fname)
        end,

        -- Single file support
        single_file_support = true,
    },
}
return {
    "CRAG666/code_runner.nvim",
    cmd = { "RunCode", "RunFile", "RunProject", "RunClose", "CRFiletype", "CRProjects" },
    keys = {
        { "<leader>rr", "<cmd>RunCode<cr>", desc = "Run code" },
        { "<leader>rf", "<cmd>RunFile<cr>", desc = "Run file" },
        { "<leader>rp", "<cmd>RunProject<cr>", desc = "Run project" },
        { "<leader>rc", "<cmd>RunClose<cr>", desc = "Close runner" },
        { "<leader>rt", "<cmd>CRFiletype<cr>", desc = "Choose filetype" },
    },
    config = function()
        require("code_runner").setup({
            -- Choose default mode (valid term, tab, float, toggle)
            mode = "term",
            -- Focus on runner window(only works on toggle, term and tab mode)
            focus = true,
            -- Start insert mode when opening the runner buffer
            startinsert = true,
            -- Path to insert on runner buffer
            insert_path = false,
            -- Terminal configuration
            term = {
                --  Position to open the terminal, this option is ignored if tab is true
                position = "bot",
                -- Window size, this option is ignored if tab is true
                size = 8,
            },
            -- Float configuration
            float = {
                close_key = "<ESC>",
                -- Window border (see ':h nvim_open_win')
                border = "rounded",

                -- Num from `0 - 1` for measurements
                height = 0.8,
                width = 0.8,
                x = 0.5,
                y = 0.5,

                -- Highlight group for floating window/border (see ':h winhl')
                border_hl = "FloatBorder",
                float_hl = "Normal",

                -- Transparency (see ':h winblend')
                blend = 0,
            },
            -- Tab configuration
            tab = {
                name = "Runner",
                number = 1,
            },
            -- Better mappings as fallback
            better_term = { -- Toggle mode replacement
                clean = false, -- Clean terminal before run
                number = 10,   -- Use terminal 10 for runner
            },
            filetype_path = "", -- No custom path, use defaults
            -- Configuration by file type
            filetype = {
                -- JavaScript/TypeScript
                javascript = "node",
                typescript = "ts-node",

                -- Python
                python = function()
                    -- Check for virtual environment
                    local venv_python = vim.fn.glob("./venv/bin/python")
                    if venv_python ~= "" then
                        return venv_python
                    else
                        return "python3"
                    end
                end,

                -- R and R Markdown
                r = "Rscript",
                rmd = function()
                    local file = vim.fn.expand("%:p")
                    return string.format('Rscript -e "rmarkdown::render(\'%s\')"', file)
                end,

                -- Lua
                lua = "lua",

                -- Shell scripts
                sh = "bash",
                zsh = "zsh",

                -- Go
                go = "go run",

                -- Rust
                rust = function()
                    local file = vim.fn.expand("%:t:r")
                    return string.format("rustc %s.rs && ./%s", file, file)
                end,

                -- C/C++
                c = function()
                    local file = vim.fn.expand("%:t:r")
                    return string.format("gcc %s.c -o %s && ./%s", file, file, file)
                end,
                cpp = function()
                    local file = vim.fn.expand("%:t:r")
                    return string.format("g++ %s.cpp -o %s && ./%s", file, file, file)
                end,

                -- Java
                java = function()
                    local file = vim.fn.expand("%:t:r")
                    return string.format("javac %s.java && java %s", file, file)
                end,

                -- HTML (open in browser)
                html = function()
                    local file = vim.fn.expand("%:p")
                    local open_cmd = vim.fn.has("mac") == 1 and "open" or
                                    vim.fn.has("unix") == 1 and "xdg-open" or "start"
                    return string.format("%s %s", open_cmd, file)
                end,

                -- Markdown (render with pandoc if available)
                markdown = function()
                    local file = vim.fn.expand("%:p")
                    local output = vim.fn.expand("%:p:r") .. ".html"
                    local open_cmd = vim.fn.has("mac") == 1 and "open" or
                                    vim.fn.has("unix") == 1 and "xdg-open" or "start"

                    if vim.fn.executable("pandoc") == 1 then
                        return string.format("pandoc %s -o %s && %s %s", file, output, open_cmd, output)
                    else
                        return string.format("%s %s", open_cmd, file)
                    end
                end,
            },
            project_path = "",
            project = {
                -- Project-specific runners
                ["package.json"] = "npm start",
                ["Cargo.toml"] = "cargo run",
                ["go.mod"] = "go run .",
                ["Makefile"] = "make run",
                ["requirements.txt"] = "python -m pip install -r requirements.txt",
                ["pyproject.toml"] = "python -m pip install -e .",
            },
        })

        -- Additional custom commands for enhanced workflow
        vim.api.nvim_create_user_command("RunLine", function()
            -- Save current line to temp file and run it
            local line = vim.api.nvim_get_current_line()
            local ft = vim.bo.filetype
            local temp_file = vim.fn.tempname() .. "." .. ft

            -- Write line to temp file
            vim.fn.writefile({ line }, temp_file)

            -- Set temporary file and run
            local saved_file = vim.fn.expand("%")
            vim.cmd("edit " .. temp_file)
            vim.cmd("RunCode")
            vim.cmd("edit " .. saved_file)

            -- Clean up
            vim.fn.delete(temp_file)
        end, { desc = "Run current line" })

        vim.api.nvim_create_user_command("RunSelection", function()
            -- Get visual selection
            local start_pos = vim.fn.getpos("'<")
            local end_pos = vim.fn.getpos("'>")
            local lines = vim.fn.getline(start_pos[2], end_pos[2])

            if #lines == 0 then
                vim.notify("No selection found", vim.log.levels.WARN)
                return
            end

            local ft = vim.bo.filetype
            local temp_file = vim.fn.tempname() .. "." .. ft

            -- Write selection to temp file
            vim.fn.writefile(lines, temp_file)

            -- Set temporary file and run
            local saved_file = vim.fn.expand("%")
            vim.cmd("edit " .. temp_file)
            vim.cmd("RunCode")
            vim.cmd("edit " .. saved_file)

            -- Clean up
            vim.fn.delete(temp_file)
        end, { desc = "Run visual selection", range = true })

        -- Key mappings for custom commands
        vim.keymap.set("n", "<leader>rl", "<cmd>RunLine<cr>", { desc = "Run current line" })
        vim.keymap.set("v", "<leader>rs", "<cmd>RunSelection<cr>", { desc = "Run selection" })

        -- Quick run for specific file types
        vim.keymap.set("n", "<leader>rR", function()
            local ft = vim.bo.filetype
            if ft == "python" then
                vim.cmd("!python3 %")
            elseif ft == "javascript" then
                vim.cmd("!node %")
            elseif ft == "lua" then
                vim.cmd("luafile %")
            elseif ft == "r" then
                vim.cmd("!Rscript %")
            elseif ft == "sh" or ft == "bash" then
                vim.cmd("!bash %")
            else
                vim.cmd("RunCode")
            end
        end, { desc = "Quick run file" })
    end,
}
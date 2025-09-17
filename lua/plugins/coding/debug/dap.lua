return {
    {
        "mfussenegger/nvim-dap",
        event = "VeryLazy",
        dependencies = {
            "rcarriga/nvim-dap-ui",
            "theHamsta/nvim-dap-virtual-text",
            "nvim-neotest/nvim-nio",
        },
        keys = {
            { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle breakpoint" },
            { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input("Condition: ")) end, desc = "Conditional breakpoint" },
            { "<leader>dc", function() require("dap").continue() end, desc = "Continue" },
            { "<leader>dC", function() require("dap").run_to_cursor() end, desc = "Run to cursor" },
            { "<leader>dg", function() require("dap").goto_() end, desc = "Go to line (no execute)" },
            { "<leader>di", function() require("dap").step_into() end, desc = "Step into" },
            { "<leader>dj", function() require("dap").down() end, desc = "Down" },
            { "<leader>dk", function() require("dap").up() end, desc = "Up" },
            { "<leader>dl", function() require("dap").run_last() end, desc = "Run last" },
            { "<leader>do", function() require("dap").step_over() end, desc = "Step over" },
            { "<leader>dO", function() require("dap").step_out() end, desc = "Step out" },
            { "<leader>dp", function() require("dap").pause() end, desc = "Pause" },
            { "<leader>dr", function() require("dap").repl.toggle() end, desc = "Toggle REPL" },
            { "<leader>ds", function() require("dap").session() end, desc = "Session" },
            { "<leader>dt", function() require("dap").terminate() end, desc = "Terminate" },
            { "<leader>dw", function() require("dap.ui.widgets").hover() end, desc = "Widgets" },
            { "<leader>du", function() require("dapui").toggle() end, desc = "Toggle DAP UI" },
            { "<leader>de", function() require("dapui").eval() end, desc = "Eval", mode = {"n", "v"} },
        },
        config = function()
            local dap = require("dap")
            local dapui = require("dapui")

            -- Setup DAP UI
            dapui.setup({
                icons = { expanded = "▾", collapsed = "▸", current_frame = "▸" },
                mappings = {
                    -- Use a table to apply multiple mappings
                    expand = { "<CR>", "<2-LeftMouse>" },
                    open = "o",
                    remove = "d",
                    edit = "e",
                    repl = "r",
                    toggle = "t",
                },
                -- Use this to override mappings for specific elements
                element_mappings = {},
                -- Expand lines larger than the window
                expand_lines = vim.fn.has("nvim-0.7") == 1,
                layouts = {
                    {
                        elements = {
                            -- Elements can be strings or table with id and size keys.
                            { id = "scopes", size = 0.25 },
                            "breakpoints",
                            "stacks",
                            "watches",
                        },
                        size = 40, -- 40 columns
                        position = "left",
                    },
                    {
                        elements = {
                            "repl",
                            "console",
                        },
                        size = 0.25, -- 25% of total lines
                        position = "bottom",
                    },
                },
                controls = {
                    -- Requires Neovim nightly (or 0.8 when released)
                    -- Uses nvim-web-devicons for icons by default, if available
                    -- Controls for element_mappings
                    enabled = true,
                    -- Display controls in this element
                    element = "repl",
                    icons = {
                        pause = "",
                        play = "",
                        step_into = "",
                        step_over = "",
                        step_out = "",
                        step_back = "",
                        run_last = "↻",
                        terminate = "□",
                    },
                },
                floating = {
                    max_height = nil, -- These can be integers or a float between 0 and 1.
                    max_width = nil,  -- Floats will be treated as percentage of your screen.
                    border = "single", -- Border style. Can be "single", "double" or "rounded"
                    mappings = {
                        close = { "q", "<Esc>" },
                    },
                },
                windows = { indent = 1 },
                render = {
                    max_type_length = nil, -- Can be integer or nil.
                    max_value_lines = 100, -- Can be integer or nil.
                },
            })

            -- Virtual text setup
            require("nvim-dap-virtual-text").setup({
                enabled = true,                        -- enable this plugin (the default)
                enabled_commands = true,               -- create commands DapVirtualTextEnable, DapVirtualTextDisable, DapVirtualTextToggle, (DapVirtualTextForceRefresh for refreshing when debug adapter did not notify its termination)
                highlight_changed_variables = true,    -- highlight changed values with NvimDapVirtualTextChanged, else always NvimDapVirtualText
                highlight_new_as_changed = false,      -- highlight new variables in the same way as changed variables (if highlight_changed_variables)
                show_stop_reason = true,               -- show stop reason when stopped for exceptions
                commented = false,                     -- prefix virtual text with comment string
                only_first_definition = true,          -- only show virtual text at first definition (if there are multiple)
                all_references = false,                -- show virtual text on all all references of the variable (not only definitions)
                clear_on_continue = false,             -- clear virtual text on "continue" (might cause flickering when stepping)
                --- A callback that determines how a variable is displayed or whether it should be omitted
                display_callback = function(variable, buf, stackframe, node, options)
                    if options.virt_text_pos == 'inline' then
                        return ' = ' .. variable.value
                    else
                        return variable.name .. ' = ' .. variable.value
                    end
                end,
                -- position of virtual text, see `:h nvim_buf_set_extmark()`, default tries to inline the virtual text. Use 'eol' to set to end of line
                virt_text_pos = vim.fn.has 'nvim-0.10' == 1 and 'inline' or 'eol',

                -- experimental features:
                all_frames = false,                    -- show virtual text for all stack frames not only current. Only works for debugpy on my machine.
                virt_lines = false,                    -- show virtual lines instead of virtual text (will flicker!)
                virt_text_win_col = nil                -- position the virtual text at a fixed window column (starting from the first text column) ,
                -- e.g. 80 to position at column 80, see `:h nvim_buf_set_extmark()`
            })

            -- Auto open/close DAP UI
            dap.listeners.after.event_initialized["dapui_config"] = function()
                dapui.open()
            end
            dap.listeners.before.event_terminated["dapui_config"] = function()
                dapui.close()
            end
            dap.listeners.before.event_exited["dapui_config"] = function()
                dapui.close()
            end

            -- Breakpoint symbols
            vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DapBreakpoint", linehl = "", numhl = "" })
            vim.fn.sign_define("DapBreakpointCondition", { text = "◐", texthl = "DapBreakpointCondition", linehl = "", numhl = "" })
            vim.fn.sign_define("DapLogPoint", { text = "◆", texthl = "DapLogPoint", linehl = "", numhl = "" })
            vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DapStopped", linehl = "DapStoppedLine", numhl = "" })
            vim.fn.sign_define("DapBreakpointRejected", { text = "○", texthl = "DapBreakpointRejected", linehl = "", numhl = "" })

            -- Language-specific configurations
            -- Python configuration (requires debugpy: pip install debugpy)
            dap.adapters.python = {
                type = "executable",
                command = "python3",
                args = { "-m", "debugpy.adapter" },
            }

            dap.configurations.python = {
                {
                    type = "python",
                    request = "launch",
                    name = "Launch file",
                    program = "${file}",
                    pythonPath = function()
                        -- Check for virtual environment
                        local venv_python = vim.fn.glob("./venv/bin/python")
                        if venv_python ~= "" then
                            return venv_python
                        else
                            return "python3"
                        end
                    end,
                },
                {
                    type = "python",
                    request = "launch",
                    name = "Launch file with arguments",
                    program = "${file}",
                    args = function()
                        local args_string = vim.fn.input("Arguments: ")
                        return vim.split(args_string, " ")
                    end,
                    pythonPath = function()
                        local venv_python = vim.fn.glob("./venv/bin/python")
                        if venv_python ~= "" then
                            return venv_python
                        else
                            return "python3"
                        end
                    end,
                },
            }

            -- Node.js configuration (requires node debug adapter)
            dap.adapters.node2 = {
                type = "executable",
                command = "node",
                args = { vim.fn.stdpath("data") .. "/mason/packages/node-debug2-adapter/node_modules/node-debug2/out/src/nodeDebug.js" },
            }

            dap.configurations.javascript = {
                {
                    name = "Launch",
                    type = "node2",
                    request = "launch",
                    program = "${file}",
                    cwd = vim.fn.getcwd(),
                    sourceMaps = true,
                    protocol = "inspector",
                    console = "integratedTerminal",
                },
                {
                    name = "Attach to process",
                    type = "node2",
                    request = "attach",
                    processId = require("dap.utils").pick_process,
                },
            }

            -- Add TypeScript support
            dap.configurations.typescript = dap.configurations.javascript

            -- Lua configuration (requires local-lua-debugger-vscode)
            dap.adapters["local-lua"] = {
                type = "executable",
                command = "node",
                args = {
                    vim.fn.stdpath("data") .. "/mason/packages/local-lua-debugger-vscode/extension/debugAdapter.js"
                },
                enrich_config = function(config, on_config)
                    if not config["extensionPath"] then
                        local c = vim.deepcopy(config)
                        c.extensionPath = vim.fn.stdpath("data") .. "/mason/packages/local-lua-debugger-vscode/"
                        on_config(c)
                    else
                        on_config(config)
                    end
                end,
            }

            dap.configurations.lua = {
                {
                    name = "Current file (local-lua-dbg, lua)",
                    type = "local-lua",
                    request = "launch",
                    cwd = "${workspaceFolder}",
                    program = {
                        lua = "lua5.1",
                        file = "${file}",
                    },
                    args = {},
                },
            }

            -- Custom commands for easier debugging
            vim.api.nvim_create_user_command("DapUIToggle", function()
                dapui.toggle()
            end, {})

            vim.api.nvim_create_user_command("DapClearBreakpoints", function()
                dap.clear_breakpoints()
                vim.notify("All breakpoints cleared", vim.log.levels.INFO)
            end, {})

            vim.api.nvim_create_user_command("DapListBreakpoints", function()
                local breakpoints = dap.list_breakpoints()
                if vim.tbl_isempty(breakpoints) then
                    vim.notify("No breakpoints set", vim.log.levels.INFO)
                else
                    vim.notify("Breakpoints: " .. vim.inspect(breakpoints), vim.log.levels.INFO)
                end
            end, {})
        end,
    },
}
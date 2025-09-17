return {
    "Vigemus/iron.nvim",
    keys = {
        { "<leader>ir", "<cmd>IronRepl<cr>", desc = "Iron REPL" },
        { "<leader>iR", "<cmd>IronRestart<cr>", desc = "Iron restart" },
        { "<leader>if", "<cmd>IronFocus<cr>", desc = "Iron focus" },
        { "<leader>ih", "<cmd>IronHide<cr>", desc = "Iron hide" },
        { "<leader>ic", "<cmd>IronSend<cr>", desc = "Iron send", mode = { "n", "v" } },
        { "<leader>il", function() require("iron.core").send_line() end, desc = "Iron send line" },
        { "<leader>im", function() require("iron.core").send_mark() end, desc = "Iron send mark" },
        { "<leader>ip", function() require("iron.core").send_paragraph() end, desc = "Iron send paragraph" },
        { "<leader>iu", function() require("iron.core").send_until_cursor() end, desc = "Iron send until cursor" },
    },
    config = function()
        local iron = require("iron.core")

        iron.setup({
            config = {
                -- Whether a repl should be discarded or not
                scratch_repl = true,
                -- Your repl definitions come here
                repl_definition = {
                    sh = {
                        -- Can be a table or a function that
                        -- returns a table (see below)
                        command = { "zsh" }
                    },
                    python = {
                        command = function()
                            -- Check for virtual environment
                            local venv_python = vim.fn.glob("./venv/bin/python")
                            if venv_python ~= "" then
                                return { venv_python }
                            else
                                return { "python3" }
                            end
                        end,
                        format = require("iron.fts.common").bracketed_paste
                    },
                    r = {
                        command = { "R", "--quiet", "--no-save" },
                        format = require("iron.fts.common").bracketed_paste
                    },
                    lua = {
                        command = { "lua" }
                    },
                    javascript = {
                        command = { "node" }
                    },
                    typescript = {
                        command = { "ts-node" }
                    },
                    julia = {
                        command = { "julia" }
                    },
                    scala = {
                        command = { "scala" }
                    },
                    clojure = {
                        command = { "lein", "repl" }
                    },
                    ruby = {
                        command = { "irb" }
                    },
                    haskell = {
                        command = { "ghci" }
                    },
                    scheme = {
                        command = { "racket" }
                    },
                    erlang = {
                        command = { "erl" }
                    },
                    elixir = {
                        command = { "iex" }
                    },
                    php = {
                        command = { "php", "-a" }
                    },
                    perl = {
                        command = { "perl", "-de0" }
                    },
                    go = {
                        command = { "goimports" }
                    }
                },
                -- How the repl window will be displayed
                -- See below for more information
                repl_open_cmd = require('iron.view').bottom(40),
            },
            -- Iron doesn't set keymaps by default anymore.
            -- You can set them here or manually add keymaps to the maps you are interested in
            keymaps = {
                send_motion = "<space>ic",
                visual_send = "<space>ic",
                send_file = "<space>if",
                send_line = "<space>il",
                send_paragraph = "<space>ip",
                send_until_cursor = "<space>iu",
                send_mark = "<space>im",
                mark_motion = "<space>imc",
                mark_visual = "<space>imc",
                remove_mark = "<space>imd",
                cr = "<space>i<cr>",
                interrupt = "<space>i<space>",
                exit = "<space>iq",
                clear = "<space>ix",
            },
            -- If the highlight is on, you can change how it looks
            -- For the available options, check nvim_set_hl
            highlight = {
                italic = true
            },
            ignore_blank_lines = true, -- ignore blank lines when sending visual select lines
        })

        -- Custom functions for enhanced workflow
        local function send_cell()
            -- Send cell delimited by ## comments (Python/R style)
            local current_line = vim.fn.line('.')
            local total_lines = vim.fn.line('$')

            -- Find start of current cell
            local start_line = current_line
            for i = current_line, 1, -1 do
                local line = vim.fn.getline(i)
                if line:match('^##') then
                    start_line = i + 1
                    break
                elseif i == 1 then
                    start_line = 1
                    break
                end
            end

            -- Find end of current cell
            local end_line = current_line
            for i = current_line + 1, total_lines do
                local line = vim.fn.getline(i)
                if line:match('^##') then
                    end_line = i - 1
                    break
                elseif i == total_lines then
                    end_line = total_lines
                    break
                end
            end

            -- Send the cell
            if start_line <= end_line then
                local lines = vim.fn.getline(start_line, end_line)
                iron.send(nil, lines)
                vim.notify(string.format("Sent cell (lines %d-%d)", start_line, end_line), vim.log.levels.INFO)
            end
        end

        local function send_function()
            -- Send the current function (works for Python, R, etc.)
            local ts_utils = require('nvim-treesitter.ts_utils')
            local current_node = ts_utils.get_node_at_cursor()

            if not current_node then
                vim.notify("No treesitter node found", vim.log.levels.WARN)
                return
            end

            -- Find function node
            local function_node = current_node
            while function_node do
                local node_type = function_node:type()
                if node_type == "function_definition" or
                   node_type == "function_declaration" or
                   node_type == "method_definition" then
                    break
                end
                function_node = function_node:parent()
            end

            if function_node then
                local start_row, _, end_row, _ = function_node:range()
                local lines = vim.fn.getline(start_row + 1, end_row + 1)
                iron.send(nil, lines)
                vim.notify(string.format("Sent function (lines %d-%d)", start_row + 1, end_row + 1), vim.log.levels.INFO)
            else
                vim.notify("No function found at cursor", vim.log.levels.WARN)
            end
        end

        local function send_class()
            -- Send the current class
            local ts_utils = require('nvim-treesitter.ts_utils')
            local current_node = ts_utils.get_node_at_cursor()

            if not current_node then
                vim.notify("No treesitter node found", vim.log.levels.WARN)
                return
            end

            -- Find class node
            local class_node = current_node
            while class_node do
                local node_type = class_node:type()
                if node_type == "class_definition" or node_type == "class_declaration" then
                    break
                end
                class_node = class_node:parent()
            end

            if class_node then
                local start_row, _, end_row, _ = class_node:range()
                local lines = vim.fn.getline(start_row + 1, end_row + 1)
                iron.send(nil, lines)
                vim.notify(string.format("Sent class (lines %d-%d)", start_row + 1, end_row + 1), vim.log.levels.INFO)
            else
                vim.notify("No class found at cursor", vim.log.levels.WARN)
            end
        end

        -- Additional key mappings for enhanced workflow
        vim.keymap.set("n", "<leader>ie", send_cell, { desc = "Iron send cell" })
        vim.keymap.set("n", "<leader>iF", send_function, { desc = "Iron send function" })
        vim.keymap.set("n", "<leader>iC", send_class, { desc = "Iron send class" })

        -- Python-specific enhancements
        vim.keymap.set("n", "<leader>iI", function()
            if vim.bo.filetype == "python" then
                iron.send(nil, {"import numpy as np", "import pandas as pd", "import matplotlib.pyplot as plt"})
                vim.notify("Sent common Python imports", vim.log.levels.INFO)
            else
                vim.notify("Python imports only work in Python files", vim.log.levels.WARN)
            end
        end, { desc = "Iron send Python imports" })

        -- R-specific enhancements
        vim.keymap.set("n", "<leader>iL", function()
            if vim.bo.filetype == "r" then
                iron.send(nil, {"library(tidyverse)", "library(ggplot2)", "library(dplyr)"})
                vim.notify("Sent common R libraries", vim.log.levels.INFO)
            else
                vim.notify("R libraries only work in R files", vim.log.levels.WARN)
            end
        end, { desc = "Iron send R libraries" })

        -- Clear REPL
        vim.keymap.set("n", "<leader>ix", function()
            local ft = vim.bo.filetype
            if ft == "python" then
                iron.send(nil, {"clear"}) -- For IPython
            elseif ft == "r" then
                iron.send(nil, {"rm(list=ls())"}) -- Clear R workspace
            else
                iron.send(nil, {"clear"}) -- General clear command
            end
        end, { desc = "Iron clear REPL" })

        -- View REPL output in floating window
        vim.keymap.set("n", "<leader>iv", function()
            local repl_buf = iron.get_current_repl()
            if repl_buf then
                local lines = vim.api.nvim_buf_get_lines(repl_buf, -50, -1, false) -- Last 50 lines
                local content = table.concat(lines, "\n")

                -- Create floating window
                local width = math.floor(vim.o.columns * 0.8)
                local height = math.floor(vim.o.lines * 0.8)
                local row = math.floor((vim.o.lines - height) / 2)
                local col = math.floor((vim.o.columns - width) / 2)

                local buf = vim.api.nvim_create_buf(false, true)
                vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
                vim.api.nvim_buf_set_option(buf, 'readonly', true)
                vim.api.nvim_buf_set_option(buf, 'modifiable', false)

                local opts = {
                    relative = 'editor',
                    width = width,
                    height = height,
                    row = row,
                    col = col,
                    style = 'minimal',
                    border = 'rounded',
                    title = 'REPL Output',
                    title_pos = 'center',
                }

                local win = vim.api.nvim_open_win(buf, true, opts)
                vim.api.nvim_win_set_option(win, 'wrap', true)

                -- Close on escape
                vim.keymap.set('n', '<Esc>', '<cmd>q<cr>', { buffer = buf, silent = true })
                vim.keymap.set('n', 'q', '<cmd>q<cr>', { buffer = buf, silent = true })
            else
                vim.notify("No active REPL found", vim.log.levels.WARN)
            end
        end, { desc = "Iron view REPL output" })

        -- Create user commands
        vim.api.nvim_create_user_command("IronSendCell", send_cell, {})
        vim.api.nvim_create_user_command("IronSendFunction", send_function, {})
        vim.api.nvim_create_user_command("IronSendClass", send_class, {})
    end,
}
return {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
        local lualine = require("lualine")

        local colors = {
            bg = "#202328",
            fg = "#bbc2cf",
            yellow = "#ECBE7B",
            cyan = "#008080",
            darkblue = "#081633",
            green = "#98be65",
            orange = "#FF8800",
            violet = "#a9a1e1",
            magenta = "#c678dd",
            blue = "#51afef",
            red = "#ec5f67",
        }

        local config = {
            options = {
                component_separators = "",
                section_separators = "",
                globalstatus = false,      -- Use separate status line for each window/split
                theme = {
                    normal = { c = { fg = colors.fg, bg = colors.bg } },
                    inactive = { c = { fg = colors.fg, bg = colors.bg } },
                },
            },
            sections = {
                lualine_a = {},
                lualine_b = {},
                lualine_y = {},
                lualine_z = {},
                lualine_c = {},
                lualine_x = {},
            },
            inactive_sections = {
                lualine_a = {},
                lualine_b = {},
                lualine_y = {},
                lualine_z = {},
                lualine_c = {},
                lualine_x = {},
            },
        }

        local function ins_left(component)
            table.insert(config.sections.lualine_c, component)
        end

        local function ins_right(component)
            table.insert(config.sections.lualine_x, component)
        end

        ins_left({
            function()
                return "▊"
            end,
            color = { fg = colors.blue },
            padding = { left = 0, right = 1 },
        })

        ins_left({
            function()
                return ""
            end,
            color = function()
                local mode_color = {
                    n = colors.red,
                    i = colors.green,
                    v = colors.blue,
                    [""] = colors.blue,
                    V = colors.blue,
                    c = colors.magenta,
                    no = colors.red,
                    s = colors.orange,
                    S = colors.orange,
                    [""] = colors.orange,
                    ic = colors.yellow,
                    R = colors.violet,
                    Rv = colors.violet,
                    cv = colors.red,
                    ce = colors.red,
                    r = colors.cyan,
                    rm = colors.cyan,
                    ["r?"] = colors.cyan,
                    ["!"] = colors.red,
                    t = colors.red,
                }
                return { fg = mode_color[vim.fn.mode()] }
            end,
            padding = { right = 1 },
        })

        ins_left({
            "filename",
            file_status = true,
            newfile_status = false,
            path = 4,              -- Filename and parent dir, with tilde as home directory
            shorting_target = 20,  -- Shorter target for narrow splits
            symbols = {
                modified = '*',        -- Shorter modified indicator
                readonly = 'RO',       -- Shorter readonly indicator
                unnamed = '[New]',
                newfile = '[New]',
            },
            color = { fg = colors.magenta, gui = "bold" },
        })

        ins_left({
            "diagnostics",
            sources = { "nvim_diagnostic" },
            symbols = { error = "E", warn = "W", info = "I" },  -- Shorter symbols
            diagnostics_color = {
                color_error = { fg = colors.red },
                color_warn = { fg = colors.yellow },
                color_info = { fg = colors.cyan },
            },
        })

        ins_left({
            function()
                return "%="
            end,
        })

        ins_left({
            function()
                local msg = "No Active Lsp"
                local buf_ft = vim.api.nvim_buf_get_option(0, "filetype")
                local clients = vim.lsp.get_clients()
                if next(clients) == nil then
                    return msg
                end
                for _, client in ipairs(clients) do
                    local filetypes = client.config.filetypes
                    if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
                        return client.name
                    end
                end
                return msg
            end,
            icon = " LSP:",
            color = { fg = "#ffffff", gui = "bold" },
        })


        ins_right({
            "branch",
            icon = "",
            color = { fg = colors.violet, gui = "bold" },
            fmt = function(str)
                return str:sub(1, 10)  -- Limit branch name to 10 characters
            end,
        })

        ins_right({
            "diff",
            symbols = { added = "+", modified = "~", removed = "-" },  -- Shorter symbols
            diff_color = {
                added = { fg = colors.green },
                modified = { fg = colors.orange },
                removed = { fg = colors.red },
            },
            cond = function()
                return vim.fn.winwidth(0) > 60  -- Show only when window is reasonably wide
            end,
        })

        ins_right({
            function()
                return "▊"
            end,
            color = { fg = colors.blue },
            padding = { left = 1 },
        })

        lualine.setup(config)
    end,
}
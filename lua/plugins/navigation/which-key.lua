return {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
        delay = 500,
        preset = "modern",
        icons = {
            group = "",
            breadcrumb = "»",
            separator = "➜",
        },
    },
    config = function(_, opts)
        local wk = require("which-key")
        wk.setup(opts)

        -- Document existing keymaps with helpful descriptions
        wk.add({
            -- Leader key groups
            { "<leader>c", group = "Code" },
            { "<leader>ca", desc = "Code actions" },
            { "<leader>rn", desc = "Rename symbol" },
            { "<leader>D", desc = "Type definition" },

            { "<leader>d", group = "Diagnostics" },
            { "<leader>de", desc = "Show error messages" },
            { "<leader>q", desc = "Open diagnostics list" },

            -- Explorer
            { "<leader>e", desc = "Toggle file explorer" },

            -- Find/Search with Telescope
            { "<leader>f", group = "Find" },
            { "<leader>ff", desc = "Find files" },
            { "<leader>fg", desc = "Find text" },
            { "<leader>fb", desc = "Find buffers" },
            { "<leader>fh", desc = "Find help" },
            { "<leader>fr", desc = "Find recent files" },
            { "<leader>fc", desc = "Find commands" },
            { "<leader>fk", desc = "Find keymaps" },
            { "<leader>ft", desc = "Find Telescope pickers" },
            { "<leader>fF", desc = "Find all files (including ignored)" },
            { "<leader>fG", desc = "Find text in all files" },

            -- Search (alternative keymaps)
            { "<leader>s", group = "Search" },
            { "<leader>sf", desc = "Search files" },
            { "<leader>sg", desc = "Search by grep" },
            { "<leader>sw", desc = "Search current word" },
            { "<leader>sh", desc = "Search help" },
            { "<leader>sk", desc = "Search keymaps" },
            { "<leader>ss", desc = "Search select Telescope" },
            { "<leader>sd", desc = "Search diagnostics" },
            { "<leader>sr", desc = "Search resume" },
            { "<leader>s.", desc = "Search recent files" },
            { "<leader>s/", desc = "Search in open files" },

            -- Git
            { "<leader>g", group = "Git" },
            { "<leader>gf", desc = "Find git files" },
            { "<leader>gc", desc = "Git commits" },
            { "<leader>gb", desc = "Git branches" },
            { "<leader>gs", desc = "Git status" },
            { "<leader>gg", desc = "Neogit" },
            { "<leader>gp", desc = "Git push" },
            { "<leader>gP", desc = "Git pull" },
            { "<leader>ga", desc = "Git add all" },
            { "<leader>gA", desc = "Git add current file" },
            { "<leader>gco", desc = "Git checkout" },
            { "<leader>gC", desc = "Git commit" },
            { "<leader>gd", desc = "Git diff split" },
            { "<leader>gl", desc = "Git log" },
            { "<leader>gL", desc = "Git log oneline" },
            { "<leader>gS", desc = "Git stash" },
            { "<leader>gt", desc = "Git stash pop" },
            { "<leader>gw", desc = "Git write (add current file)" },
            { "<leader>gx", desc = "Git delete current file" },
            { "<leader>G", desc = "Git status (fugitive)" },
            { "gd", desc = "Go to definition" },
            { "gD", desc = "Go to declaration" },
            { "gr", desc = "Show references" },
            { "gi", desc = "Go to implementation" },

            -- LSP
            { "<leader>l", group = "LSP" },
            { "<leader>ls", desc = "Document symbols" },
            { "<leader>lS", desc = "Workspace symbols" },
            { "<leader>lr", desc = "References" },
            { "<leader>ld", desc = "Diagnostics" },
            { "<leader>lf", desc = "Format file" },

            -- Brackets for diagnostics
            { "[", group = "Previous" },
            { "[d", desc = "Previous diagnostic" },
            { "]", group = "Next" },
            { "]d", desc = "Next diagnostic" },

            -- Documentation
            { "K", desc = "Hover documentation" },
            { "<C-k>", desc = "Signature help" },

            -- Window navigation (your existing keymaps)
            { "<C-h>", desc = "Focus left window" },
            { "<C-j>", desc = "Focus lower window" },
            { "<C-k>", desc = "Focus upper window" },
            { "<C-l>", desc = "Focus right window" },

            -- Special keymaps
            { "<leader><leader>", desc = "Find buffers" },
            { "<leader>/", desc = "Search in current buffer" },

            -- Window management
            { "<leader>w", group = "Windows" },
            { "<leader>wv", desc = "Split window vertically" },
            { "<leader>wh", desc = "Split window horizontally" },
            { "<leader>we", desc = "Make splits equal size" },
            { "<leader>wx", desc = "Close current split" },

            -- Split creation (alternative)
            { "<leader>vs", desc = "Open vertical split" },

            -- Window resizing
            { "<leader>w+", desc = "Increase window height" },
            { "<leader>w-", desc = "Decrease window height" },
            { "<leader>w>", desc = "Increase window width" },
            { "<leader>w<", desc = "Decrease window width" },

            -- Git hunks and version control
            { "<leader>h", group = "Git Hunks" },
            { "<leader>hs", desc = "Stage hunk" },
            { "<leader>hr", desc = "Reset hunk" },
            { "<leader>hS", desc = "Stage buffer" },
            { "<leader>hu", desc = "Undo stage hunk" },
            { "<leader>hR", desc = "Reset buffer" },
            { "<leader>hp", desc = "Preview hunk" },
            { "<leader>hb", desc = "Blame line" },
            { "<leader>hd", desc = "Diff this" },
            { "<leader>hD", desc = "Diff this ~" },

            -- Buffer management (simplified)
            { "<leader>b", group = "Buffers" },
            { "<leader>bd", desc = "Delete buffer" },
            { "<leader>bn", desc = "Next buffer" },
            { "<leader>bp", desc = "Previous buffer" },

            -- Toggles
            { "<leader>t", group = "Toggle" },
            { "<leader>tb", desc = "Toggle line blame" },
            { "<leader>td", desc = "Toggle deleted" },

            -- Comment keymaps
            { "gc", group = "Comment" },
            { "gcc", desc = "Comment line" },
            { "gbc", desc = "Comment block" },
            { "gcO", desc = "Comment line above" },
            { "gco", desc = "Comment line below" },
            { "gcA", desc = "Comment end of line" },

            -- Run/Execute
            { "<leader>r", group = "Run/Execute" },
            { "<leader>rr", desc = "Run code" },
            { "<leader>rf", desc = "Run file" },
            { "<leader>rp", desc = "Run project" },
            { "<leader>rc", desc = "Close runner" },
            { "<leader>rt", desc = "Choose filetype" },
            { "<leader>rq", desc = "Quick run current file" },
            { "<leader>rl", desc = "Run current line" },
            { "<leader>rs", desc = "Run selection" },
            { "<leader>rR", desc = "Quick run file" },
            { "<leader>ra", desc = "Run with arguments" },
            { "<leader>rP", desc = "Quick profile" },

            -- Debug (DAP)
            { "<leader>d", group = "Debug/Diff" },
            { "<leader>db", desc = "Toggle breakpoint" },
            { "<leader>dB", desc = "Conditional breakpoint" },
            { "<leader>dc", desc = "Debug continue" },
            { "<leader>dC", desc = "Run to cursor" },
            { "<leader>dg", desc = "Go to line (no execute)" },
            { "<leader>di", desc = "Step into" },
            { "<leader>dj", desc = "Down" },
            { "<leader>dk", desc = "Up" },
            { "<leader>dl", desc = "Run last" },
            { "<leader>do", desc = "Step over" },
            { "<leader>dO", desc = "Step out" },
            { "<leader>dp", desc = "Pause" },
            { "<leader>dr", desc = "Toggle REPL" },
            { "<leader>ds", desc = "Session" },
            { "<leader>dt", desc = "Terminate" },
            { "<leader>dw", desc = "Widgets" },
            { "<leader>du", desc = "Toggle DAP UI" },
            { "<leader>dv", desc = "DiffView open" },
            { "<leader>dD", desc = "DiffView close" },
            { "<leader>dh", desc = "DiffView file history" },
            { "<leader>df", desc = "DiffView toggle files" },

            -- Iron REPL
            { "<leader>i", group = "Iron REPL" },
            { "<leader>ir", desc = "Iron REPL" },
            { "<leader>iR", desc = "Iron restart" },
            { "<leader>if", desc = "Iron focus" },
            { "<leader>ih", desc = "Iron hide" },
            { "<leader>ic", desc = "Iron send" },
            { "<leader>il", desc = "Iron send line" },
            { "<leader>im", desc = "Iron send mark" },
            { "<leader>ip", desc = "Iron send paragraph" },
            { "<leader>iu", desc = "Iron send until cursor" },
            { "<leader>ie", desc = "Iron send cell" },
            { "<leader>iF", desc = "Iron send function" },
            { "<leader>iC", desc = "Iron send class" },
            { "<leader>iI", desc = "Iron send Python imports" },
            { "<leader>iL", desc = "Iron send R libraries" },
            { "<leader>ix", desc = "Iron clear REPL" },
            { "<leader>iv", desc = "Iron view REPL output" },

            -- Terminal
            { "<leader>t", group = "Terminal" },
            { "<leader>th", desc = "Horizontal terminal" },
            { "<leader>tv", desc = "Vertical terminal" },
            { "<leader>tf", desc = "Floating terminal" },
            { "<leader>tg", desc = "LazyGit" },
            { "<leader>tp", desc = "Python REPL" },
            { "<leader>tr", desc = "R Console" },

            -- Quick actions
            { "<leader>n", group = "Notes/New" },
            { "<leader>sn", desc = "Search Neovim files" },

            -- Help and information
            { "<leader>?", group = "Help" },
            { "<leader>?k", "<cmd>WhichKey<cr>", desc = "Show all keymaps" },
            { "<leader>?h", "<cmd>help<cr>", desc = "Open Vim help" },
            { "<leader>?t", "<cmd>Telescope help_tags<cr>", desc = "Search help tags" },
        })

        -- Show hints for common operations
        wk.add({
            mode = { "n", "v" },
            { "<leader>", group = "Leader commands" },
            { "g", group = "Go to..." },
            { "z", group = "Folding" },
            { "]", group = "Next" },
            { "[", group = "Previous" },
            { "]b", desc = "Next buffer" },
            { "[b", desc = "Previous buffer" },
            { "]c", desc = "Next git hunk" },
            { "[c", desc = "Previous git hunk" },
            { "<S-h>", desc = "Previous buffer" },
            { "<S-l>", desc = "Next buffer" },
        })

        -- Function keys for quick actions
        wk.add({
            { "<F5>", desc = "Quick run file" },
            { "<F6>", desc = "Quick compile" },
            { "<F7>", desc = "Quick test" },
            { "<F8>", desc = "Quick profile" },
        })

    end,
}
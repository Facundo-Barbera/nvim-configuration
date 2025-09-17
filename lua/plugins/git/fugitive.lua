return {
    "tpope/vim-fugitive",
    event = "VeryLazy",
    keys = {
        { "<leader>G", "<cmd>Git<cr>", desc = "Git status" },
        { "<leader>ga", "<cmd>Git add .<cr>", desc = "Git add all" },
        { "<leader>gA", "<cmd>Git add %<cr>", desc = "Git add current file" },
        { "<leader>gb", "<cmd>Git blame<cr>", desc = "Git blame" },
        { "<leader>gco", "<cmd>Git checkout<cr>", desc = "Git checkout" },
        { "<leader>gC", "<cmd>Git commit<cr>", desc = "Git commit" },
        { "<leader>gd", "<cmd>Gdiffsplit<cr>", desc = "Git diff split" },
        { "<leader>gl", "<cmd>Git log<cr>", desc = "Git log" },
        { "<leader>gL", "<cmd>Git log --oneline<cr>", desc = "Git log oneline" },
        { "<leader>gp", "<cmd>Git push<cr>", desc = "Git push" },
        { "<leader>gP", "<cmd>Git pull<cr>", desc = "Git pull" },
        { "<leader>gs", "<cmd>Git<cr>", desc = "Git status" },
        { "<leader>gS", "<cmd>Git stash<cr>", desc = "Git stash" },
        { "<leader>gt", "<cmd>Git stash pop<cr>", desc = "Git stash pop" },
        { "<leader>gw", "<cmd>Gwrite<cr>", desc = "Git write (add current file)" },
        { "<leader>gx", "<cmd>GDelete<cr>", desc = "Git delete current file" },
    },
    config = function()
        -- Create custom commands for common git operations
        vim.api.nvim_create_user_command("Gst", "Git", {})
        vim.api.nvim_create_user_command("Glog", "Git log --oneline --graph --decorate --all", {})
        vim.api.nvim_create_user_command("Glol", "Git log --oneline --graph --decorate", {})

        -- Convenient aliases
        vim.api.nvim_create_user_command("Gadd", "Git add %", {})
        vim.api.nvim_create_user_command("Gcommit", "Git commit", {})
        vim.api.nvim_create_user_command("Gpush", "Git push", {})
        vim.api.nvim_create_user_command("Gpull", "Git pull", {})
        vim.api.nvim_create_user_command("Gstash", "Git stash", {})
        vim.api.nvim_create_user_command("Gpop", "Git stash pop", {})

        -- Set up some useful autocmds
        vim.api.nvim_create_autocmd("BufReadPost", {
            pattern = "fugitive://*",
            callback = function()
                vim.opt_local.bufhidden = "delete"
            end,
        })

        -- Auto-close fugitive buffers
        vim.api.nvim_create_autocmd("User", {
            pattern = "FugitiveIndex",
            callback = function()
                vim.keymap.set("n", "q", "<cmd>bd<cr>", { buffer = true, silent = true })
            end,
        })

        -- Better git commit message editing
        vim.api.nvim_create_autocmd("FileType", {
            pattern = "gitcommit",
            callback = function()
                vim.opt_local.wrap = true
                vim.opt_local.spell = true
                vim.opt_local.textwidth = 72
                -- Start in insert mode for commit messages
                vim.cmd("startinsert")
            end,
        })

        -- Better git rebase editing
        vim.api.nvim_create_autocmd("FileType", {
            pattern = "gitrebase",
            callback = function()
                vim.opt_local.wrap = false
                vim.opt_local.spell = false
            end,
        })
    end,
}
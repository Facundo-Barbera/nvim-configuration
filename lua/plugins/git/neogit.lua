return {
    "NeogitOrg/neogit",
    dependencies = {
        "nvim-lua/plenary.nvim",         -- required
        "sindrets/diffview.nvim",        -- optional - Diff integration
        "nvim-telescope/telescope.nvim", -- optional
    },
    cmd = "Neogit",
    keys = {
        { "<leader>gg", "<cmd>Neogit<cr>", desc = "Neogit" },
        { "<leader>gc", "<cmd>Neogit commit<cr>", desc = "Git commit" },
        { "<leader>gp", "<cmd>Neogit push<cr>", desc = "Git push" },
        { "<leader>gl", "<cmd>Neogit pull<cr>", desc = "Git pull" },
    },
    config = function()
        local neogit = require("neogit")

        neogit.setup({
            -- Hides the hints at the top of the status buffer
            disable_hint = false,
            -- Disables changing the buffer highlights based on signs.
            disable_context_highlighting = false,
            -- Disables signs for sections/items/hunks
            disable_signs = false,
            -- Changes what mode the Commit Editor starts in. `true` will leave nvim in normal mode, `false` will change nvim to insert mode, and `"auto"` will change nvim to insert mode IF the commit message is empty, otherwise leaving it in normal mode.
            disable_insert_on_commit = "auto",
            -- When enabled, will watch the `.git/` directory for changes and refresh the status buffer in response to filesystem events.
            filewatcher = {
                interval = 1000,
                enabled = true,
            },
            -- Used to generate URL's for branch popup action "pull request".
            git_services = {
                ["github.com"] = "https://github.com/${owner}/${repository}/compare/${branch_name}?expand=1",
                ["bitbucket.org"] = "https://bitbucket.org/${owner}/${repository}/pull-requests/new?source=${branch_name}&t=1",
                ["gitlab.com"] = "https://gitlab.com/${owner}/${repository}/-/merge_requests/new?merge_request[source_branch]=${branch_name}",
            },
            -- Allows a different telescope sorter. Defaults to 'fuzzy_with_index_bias'
            telescope_sorter = function()
                return require("telescope").extensions.fzf.native_fzf_sorter()
            end,
            -- Persist the values of switches/options within and across sessions
            remember_settings = true,
            -- Scope persisted settings on a per-project basis
            use_per_project_settings = true,
            -- Array-like table of settings to never persist. Uses format "Filetype--cli-value"
            ignored_settings = {
                "NeogitPushPopup--force-with-lease",
                "NeogitPushPopup--force",
                "NeogitPullPopup--rebase",
                "NeogitCommitPopup--allow-empty",
                "NeogitRevertPopup--no-edit",
            },
            -- Configure highlight group features
            highlight = {
                italic = true,
                bold = true,
                underline = true
            },
            -- Set to false if you want to be responsible for creating _ALL_ keymappings
            use_default_keymaps = true,
            -- Neogit refreshes its internal state after specific events, which can be expensive depending on the repository size.
            -- Disabling `auto_refresh` will make it so you have to manually refresh the status after you have run a git command.
            auto_refresh = true,
            -- Value used for `--sort` option for `git branch` command
            -- By default, branches will be sorted by commit date descending
            -- Flag description: https://git-scm.com/docs/git-branch#Documentation/git-branch.txt---sortltkeygt
            sort_branches = "-committerdate",
            -- Change the default way of opening neogit
            kind = "tab",
            -- Disable line numbers and relative line numbers
            disable_line_numbers = true,
            -- The time after which an output console is shown for slow running commands
            console_timeout = 2000,
            -- Automatically show console if a command takes more than console_timeout milliseconds
            auto_show_console = true,
            -- Automatically close the console if the process exits cleanly
            auto_close_console = true,
            status = {
                recent_commit_count = 10,
            },
            commit_editor = {
                kind = "tab",
            },
            commit_select_view = {
                kind = "tab",
            },
            commit_view = {
                kind = "vsplit",
                verify_commit = vim.fn.executable("gpg") == 1, -- Can be set to true or false, otherwise we try to find the binary
            },
            log_view = {
                kind = "tab",
            },
            rebase_editor = {
                kind = "tab",
            },
            reflog_view = {
                kind = "tab",
            },
            merge_editor = {
                kind = "tab",
            },
            tag_editor = {
                kind = "tab",
            },
            preview_buffer = {
                kind = "split",
            },
            popup = {
                kind = "split",
            },
            signs = {
                -- { CLOSED, OPENED }
                hunk = { "", "" },
                item = { ">", "v" },
                section = { ">", "v" },
            },
            -- Each Integration is auto-detected through plugin presence, however, it can be disabled by setting to `false`
            integrations = {
                -- If enabled, use telescope for menu selection rather than vim.ui.select.
                -- Allows multi-select and some things that vim.ui.select doesn't.
                telescope = true,
                -- Neogit only provides inline diffs. If you want a more traditional way to look at diffs, you can use `diffview`.
                -- The diffview integration enables the diff popup
                diffview = true,
            },
            -- Override/add mappings
            mappings = {
                -- modify status buffer mappings
                status = {
                    -- Adds a mapping with "B" as key that does the "BranchPopup" command
                    ["B"] = "BranchPopup",
                    -- Removes the default mapping of "s"
                    ["s"] = "",
                }
            },
        })
    end,
}
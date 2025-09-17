-- Utility functions for Neovim configuration
-- Common helper functions used across the configuration

local M = {}

-- Check if a plugin is available
function M.has_plugin(plugin_name)
    local ok, _ = pcall(require, plugin_name)
    return ok
end

-- Safe require with error handling
function M.safe_require(module)
    local ok, result = pcall(require, module)
    if not ok then
        vim.notify(
            string.format("Failed to require module '%s': %s", module, result),
            vim.log.levels.ERROR
        )
        return nil
    end
    return result
end

-- Check if an executable is available
function M.executable(name)
    return vim.fn.executable(name) == 1
end

-- Get current file information
function M.get_file_info()
    return {
        path = vim.fn.expand("%:p"),
        name = vim.fn.expand("%:t"),
        stem = vim.fn.expand("%:t:r"),
        extension = vim.fn.expand("%:e"),
        dir = vim.fn.expand("%:p:h"),
        filetype = vim.bo.filetype,
    }
end

-- Create a floating window
function M.create_float(opts)
    local default_opts = {
        relative = "editor",
        width = math.floor(vim.o.columns * 0.8),
        height = math.floor(vim.o.lines * 0.8),
        style = "minimal",
        border = "rounded",
    }

    opts = vim.tbl_deep_extend("force", default_opts, opts or {})

    -- Calculate position
    opts.row = math.floor((vim.o.lines - opts.height) / 2)
    opts.col = math.floor((vim.o.columns - opts.width) / 2)

    local buf = vim.api.nvim_create_buf(false, true)
    local win = vim.api.nvim_open_win(buf, true, opts)

    return buf, win
end

-- Project detection utilities
function M.find_project_root(markers)
    markers = markers or { ".git", "package.json", "Cargo.toml", "go.mod", "pyproject.toml" }
    local current_dir = vim.fn.expand("%:p:h")

    while current_dir ~= "/" do
        for _, marker in ipairs(markers) do
            if vim.fn.filereadable(current_dir .. "/" .. marker) == 1 or
               vim.fn.isdirectory(current_dir .. "/" .. marker) == 1 then
                return current_dir
            end
        end
        current_dir = vim.fn.fnamemodify(current_dir, ":h")
    end

    return vim.fn.getcwd()
end

-- Language detection utilities
function M.get_language_info()
    local ft = vim.bo.filetype
    local file_info = M.get_file_info()

    local language_map = {
        python = { repl = "python3", runner = "python3", test = "pytest" },
        javascript = { repl = "node", runner = "node", test = "npm test" },
        typescript = { repl = "ts-node", runner = "ts-node", test = "npm test" },
        lua = { repl = "lua", runner = "lua", test = "busted" },
        r = { repl = "R", runner = "Rscript", test = "testthat" },
        go = { repl = "gore", runner = "go run", test = "go test" },
        rust = { repl = "evcxr", runner = "cargo run", test = "cargo test" },
    }

    return language_map[ft] or {}
end

-- Notification helpers
function M.info(msg, title)
    vim.notify(msg, vim.log.levels.INFO, { title = title or "Info" })
end

function M.warn(msg, title)
    vim.notify(msg, vim.log.levels.WARN, { title = title or "Warning" })
end

function M.error(msg, title)
    vim.notify(msg, vim.log.levels.ERROR, { title = title or "Error" })
end

-- Keymap helpers
function M.map(mode, lhs, rhs, opts)
    opts = opts or {}
    opts.silent = opts.silent ~= false
    vim.keymap.set(mode, lhs, rhs, opts)
end

function M.nmap(lhs, rhs, opts)
    M.map("n", lhs, rhs, opts)
end

function M.imap(lhs, rhs, opts)
    M.map("i", lhs, rhs, opts)
end

function M.vmap(lhs, rhs, opts)
    M.map("v", lhs, rhs, opts)
end

return M
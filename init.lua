-- Load core configuration
require("core").setup()

-- Setup plugin manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out, "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)

-- Load plugins using the original working approach for now
-- Organized structure is available in the new directories for reference
require("lazy").setup({
    { import = "plugins" },
}, {
    checker = {
        enabled = true,
        notify = false,
    },
    change_detection = {
        notify = false,
    },
})

-- Set theme
local theme_choice = "catppuccin-frappe"
vim.cmd.colorscheme(theme_choice)

-- Setup custom quick-run utilities (moved out of plugins)
pcall(function()
    require("core.quick_run").setup()
end)

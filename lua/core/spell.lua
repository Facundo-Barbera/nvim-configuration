-- Core spell checking configuration
-- Sets up built-in Vim spell checker with smart defaults

-- Enable spell checking globally but only show highlights for relevant filetypes
vim.opt.spell = false -- Start disabled globally
vim.opt.spelllang = { "en_us", "es" }
vim.opt.spellsuggest = "best,9"

-- Define text-heavy filetypes that benefit from spell checking
local spell_filetypes = {
    "markdown",
    "text",
    "gitcommit",
    "rst",
    "tex",
    "typst",
    "mail",
    "org",
}

-- Helper function to enable spell checking for specific filetypes
local function setup_spell_for_filetype()
    local ft = vim.bo.filetype

    -- Enable spell for text-heavy filetypes
    for _, spell_ft in ipairs(spell_filetypes) do
        if ft == spell_ft then
            vim.opt_local.spell = true
            break
        end
    end
end

-- Autocmd group for spell checking
local spell_group = vim.api.nvim_create_augroup("SpellConfig", { clear = true })

-- Auto-enable spell checking for text filetypes
vim.api.nvim_create_autocmd("FileType", {
    group = spell_group,
    pattern = spell_filetypes,
    callback = function()
        vim.opt_local.spell = true
    end,
    desc = "Enable spell checking for text-heavy filetypes",
})

-- Disable spell checking for certain filetypes where it's not useful
vim.api.nvim_create_autocmd("FileType", {
    group = spell_group,
    pattern = { "help", "terminal", "dashboard", "packer", "fzf", "NeogitStatus", "checkhealth" },
    callback = function()
        vim.opt_local.spell = false
    end,
    desc = "Disable spell checking for UI filetypes",
})

-- Additional spell checking keymaps (optional)
-- These supplement the default z= for spell suggestions
local function setup_spell_keymaps()
    -- Quick spell checking toggle
    vim.keymap.set("n", "<leader>ss", function()
        vim.opt_local.spell = not vim.opt_local.spell:get()
        local status = vim.opt_local.spell:get() and "enabled" or "disabled"
        vim.notify("Spell checking " .. status, vim.log.levels.INFO)
    end, { desc = "Toggle spell checking" })

    -- Navigate between spelling errors
    vim.keymap.set("n", "]s", "]s", { desc = "Next spelling error" })
    vim.keymap.set("n", "[s", "[s", { desc = "Previous spelling error" })

    -- Add word to dictionary
    vim.keymap.set("n", "zg", "zg", { desc = "Add word to dictionary" })

    -- Mark word as wrong
    vim.keymap.set("n", "zw", "zw", { desc = "Mark word as wrong" })
end

-- Set up keymaps
setup_spell_keymaps()
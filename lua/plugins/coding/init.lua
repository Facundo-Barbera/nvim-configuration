-- Development and coding plugins
-- Code execution, REPL, debugging, formatting

return {
    -- Code execution
    require("plugins.coding.execution.runner"),
    require("plugins.coding.execution.terminal"),

    -- REPL integration
    require("plugins.coding.repl.iron"),

    -- Debugging
    require("plugins.coding.debug.dap"),

    -- Formatting
    require("plugins.coding.format.formatter"),
}

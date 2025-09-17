-- Core editing functionality plugins
-- Syntax highlighting, completion, commenting, etc.

return {
    require("plugins.editor.treesitter"),
    require("plugins.editor.completion"),
    require("plugins.editor.autopairs"),
    require("plugins.editor.comment"),
    require("plugins.editor.indent"),
}
-- Language-specific plugins
-- R, Markdown, Quarto, etc.

return {
    require("plugins.languages.r"),
    require("plugins.languages.markdown"),
    require("plugins.languages.quarto"),
    require("plugins.languages.latex"),
}
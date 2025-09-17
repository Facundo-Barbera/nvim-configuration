-- LaTeX configuration
-- Provides automatic compilation and useful commands for LaTeX files

return {
    -- VimTeX for LaTeX support
    {
        "lervag/vimtex",
        lazy = false, -- Don't lazy load for file type detection
        ft = { "tex", "bib" },
        config = function()
            -- Set the LaTeX compiler
            vim.g.vimtex_compiler_method = "latexmk"

            -- Configure latexmk
            vim.g.vimtex_compiler_latexmk = {
                aux_dir = "out",
                out_dir = "out",
                callback = 1,
                continuous = 1,
                executable = "latexmk",
                hooks = {},
                options = {
                    "-verbose",
                    "-file-line-error",
                    "-synctex=1",
                    "-interaction=nonstopmode",
                },
            }

            -- Disable overfull/underfull \hbox and all package warnings
            vim.g.vimtex_quickfix_ignore_filters = {
                "Overfull \\\\hbox",
                "Underfull \\\\hbox",
                "Package .* Warning",
            }

            -- Set up viewer (adjust based on your system)
            if vim.fn.has("mac") == 1 then
                vim.g.vimtex_view_method = "skim"
            else
                vim.g.vimtex_view_method = "zathura"
            end

            -- Auto-compilation for main.tex files
            local latex_group = vim.api.nvim_create_augroup("LaTeXAutoCompile", { clear = true })

            vim.api.nvim_create_autocmd({ "BufWritePost" }, {
                group = latex_group,
                pattern = "main.tex",
                callback = function()
                    -- Create out directory if it doesn't exist
                    local out_dir = vim.fn.expand("%:h") .. "/out"
                    if vim.fn.isdirectory(out_dir) == 0 then
                        vim.fn.mkdir(out_dir, "p")
                    end

                    -- Start compilation
                    vim.cmd("VimtexCompile")
                end,
                desc = "Auto-compile main.tex files on save"
            })

            -- Custom commands
            vim.api.nvim_create_user_command("TexCompile", function()
                local out_dir = vim.fn.expand("%:h") .. "/out"
                if vim.fn.isdirectory(out_dir) == 0 then
                    vim.fn.mkdir(out_dir, "p")
                end
                vim.cmd("VimtexCompile")
            end, { desc = "Compile current LaTeX file" })

            vim.api.nvim_create_user_command("TexClean", function()
                vim.cmd("VimtexClean")
            end, { desc = "Clean LaTeX auxiliary files" })

            vim.api.nvim_create_user_command("TexView", function()
                vim.cmd("VimtexView")
            end, { desc = "View compiled PDF" })
        end,
    },
}
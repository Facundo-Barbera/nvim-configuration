# Personal Neovim Configuration

A modern, organized Neovim configuration focused on productivity for R, Python, and Lua.

## Features

- **Plugin manager**: `lazy.nvim` with lazy-loading for fast startup
- **LSP**: Python, R, Lua, plus easy per-server overrides in `lua/plugins/lsps/`
- **Completion**: `nvim-cmp` with LSP, buffer, path, cmdline, and snippets
- **Syntax**: `nvim-treesitter` for highlighting and textobjects
- **Navigation**: `telescope.nvim` (fzf native, ui-select) and `nvim-tree`
- **Git**: `gitsigns.nvim`, `neogit`, `diffview.nvim`, and `vim-fugitive`
- **Editing**: Comments, autopairs, indent guides
- **Terminal/Run**: `toggleterm.nvim` and a “Quick Run” workflow
- **Theme**: Catppuccin (frappe)

## Layout

- `init.lua`: boots lazy.nvim, loads plugins, sets theme, wires quick-run
- `lua/core/`: options, keymaps, commands, utils, quick_run
- `lua/plugins/init.lua`: imports plugin categories
- `lua/plugins/{editor,git,languages,lsp,navigation,ui,coding}/`: grouped plugin specs
- `lua/plugins/lsps/*.lua`: per-server LSP configs; set `manual = true` to skip Mason install

## LSP Servers (manual support)

- All servers in `lua/plugins/lsps/*.lua` are configured via `lspconfig`.
- Mason auto-installs servers unless the file exports `manual = true`.
  - Example: R uses system `r_language_server` with `manual = true`.
- Add a new server by creating `lua/plugins/lsps/<name>.lua`:
  - `return { name = "<server_name>", manual = false, config = { settings = { ... } } }`

## Quick Run

Fast one-off execution, compile, test, and profile for common languages, with output in a floating window or terminal.

- Run: `<F5>` or `<leader>rq`
- Compile: `<F6>` or `<leader>rc`
- Test: `<F7>` or `<leader>rt`
- Profile: `<F8>` or `<leader>rP`

## Custom Commands

### KnitHtml
Converts R Markdown files to HTML and opens them in the default browser.
```vim
:KnitHtml
```
- Usage: Open an `.Rmd` file and run `:KnitHtml`
- Requirements: R with `rmarkdown` package installed
- Output: Generates HTML in the same directory and opens it

## Key Mappings

### Leader Key: `<Space>`

#### File Explorer (nvim-tree)
- `<leader>e` - Toggle file explorer

#### Search/Find (Telescope)
- `<leader>ff` - Find files
- `<leader>fg` - Find text (live grep)
- `<leader>fb` - Find buffers
- `<leader>fh` - Find help
- `<leader>fr` - Find recent files
- `<leader>fc` - Find commands
- `<leader>fk` - Find keymaps

#### Window Management
- `<leader>wv` - Split window vertically
- `<leader>wh` - Split window horizontally
- `<leader>we` - Make splits equal size
- `<leader>wx` - Close current split
- `<leader>w+` - Increase window height
- `<leader>w-` - Decrease window height
- `<leader>w>` - Increase window width
- `<leader>w<` - Decrease window width

#### LSP
- `gd` - Go to definition
- `gr` - Show references
- `gi` - Go to implementation
- `K` - Hover documentation
- `<leader>ca` - Code actions
- `<leader>rn` - Rename symbol
- `<leader>de` - Show diagnostic errors
- `[d` / `]d` - Navigate diagnostics

#### Git
- `<leader>gg` - Neogit
- `<leader>gc` - Neogit commit
- `<leader>gp` - Neogit push
- `<leader>gl` - Neogit pull
- Gitsigns: `[c` / `]c` navigate hunks, `<leader>hs`/`hr` stage/reset hunk, etc.

#### Diff and Merge
- `<leader>dv` - DiffView open
- `<leader>dD` - DiffView close
- `<leader>dh` - DiffView file history
- `<leader>df` - DiffView toggle files

## First-time setup

- Start Neovim; `lazy.nvim` bootstraps automatically.
- Run `:Lazy sync` if you want to force plugin install/update.

## Theme

- Default: `catppuccin-frappe`
- Change the variant or theme in `lua/plugins/ui/themes.lua` and `init.lua`.

#### Code Execution
- `<F5>` / `<leader>rq` - Quick run current file
- `<F6>` / `<leader>rc` - Quick compile
- `<F7>` / `<leader>rt` - Quick test
- `<F8>` / `<leader>rP` - Quick profile
- `<leader>rr` - Run code (code_runner)
- `<leader>rf` - Run file
- `<leader>rp` - Run project
- `<leader>ra` - Run with arguments
- `<leader>rl` - Run current line
- `<leader>rs` - Run selection

#### REPL Integration (Iron)
- `<leader>ir` - Start REPL
- `<leader>ic` - Send to REPL
- `<leader>il` - Send line to REPL
- `<leader>ie` - Send cell to REPL
- `<leader>iF` - Send function to REPL
- `<leader>iC` - Send class to REPL
- `<leader>iI` - Send Python imports
- `<leader>iL` - Send R libraries
- `<leader>ix` - Clear REPL

#### Debugging (DAP)
- `<leader>db` - Toggle breakpoint
- `<leader>dB` - Conditional breakpoint
- `<leader>dc` - Continue
- `<leader>di` - Step into
- `<leader>do` - Step over
- `<leader>dO` - Step out
- `<leader>du` - Toggle debug UI
- `<leader>dt` - Terminate debugging

#### Terminal Management
- `<C-\>` - Toggle terminal
- `<leader>th` - Horizontal terminal
- `<leader>tv` - Vertical terminal
- `<leader>tf` - Floating terminal
- `<leader>tg` - LazyGit terminal
- `<leader>tp` - Python REPL
- `<leader>tr` - R Console

#### Buffer Navigation
- `<S-h>` / `<S-l>` - Previous/Next buffer
- `<leader>bd` - Delete buffer

## Installation

1. Backup your existing Neovim configuration
2. Clone this repository to your Neovim config directory:
   ```bash
   git clone <repository-url> ~/.config/nvim
   ```
3. Open Neovim - Lazy.nvim will automatically install plugins
4. Install language servers via Mason: `:Mason`

## Requirements

- **Neovim 0.9+**
- **Git**
- **ripgrep** (for telescope grep functionality)
- **fd** or **find** (for telescope file finding)
- **make** (for telescope-fzf-native compilation)

### Optional
- **R** with `rmarkdown` package (for KnitHtml command)
- **Python** (for Python LSP support)
- **Node.js** (for some language servers)

## Plugin List

Core plugins include:
- **Plugin Management**: lazy.nvim
- **LSP & Completion**: nvim-lspconfig, mason.nvim, nvim-cmp
- **Fuzzy Finding**: telescope.nvim
- **Syntax Highlighting**: nvim-treesitter
- **Git Integration**: gitsigns.nvim, neogit, diffview.nvim, vim-fugitive
- **File Explorer**: nvim-tree.lua
- **Code Execution**: code_runner.nvim, toggleterm.nvim
- **REPL Management**: iron.nvim
- **Debugging**: nvim-dap, nvim-dap-ui, nvim-dap-virtual-text
- **Theme**: catppuccin
- **Key Mappings**: which-key.nvim

See `lazy-lock.json` for complete plugin list with versions.

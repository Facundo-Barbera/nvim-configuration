-- Luacheck configuration for Neovim configuration
-- https://luacheck.readthedocs.io/en/stable/config.html

-- Allow these global variables (Neovim API and common Lua globals)
globals = {
  -- Neovim globals
  "vim",
  -- Standard Lua globals that might not be recognized
  "bit",
  "jit",
  "unpack", -- Lua 5.1 compatibility
}

-- Neovim-specific settings
std = "luajit+busted"

-- Ignore certain warnings
ignore = {
  "212", -- Unused argument
  "213", -- Unused loop variable
  "631", -- Line is too long (we'll let stylua handle formatting)
}

-- Don't check these directories/files
exclude_files = {
  "lazy-lock.json",
  "**/lazy-lock.json",
  ".git/**",
  "temp/**",
  "spell/**/*.spl", -- Compiled spell files
}

-- Set max line length (stylua will handle formatting)
max_line_length = false

-- Allow unused variables starting with underscore
unused_args = false
unused = false

-- Files/patterns specific settings
files = {
  -- Plugin configuration files might have unused variables for lazy loading
  ["lua/plugins/**/*.lua"] = {
    ignore = { "212" }, -- Allow unused arguments in plugin configs
  },
  -- Core files should be stricter
  ["lua/core/**/*.lua"] = {
    unused = true,
  },
}
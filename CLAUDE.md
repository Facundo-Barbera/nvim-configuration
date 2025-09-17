# AGENTS.md

## Purpose / Agent Role

This file provides guidance to AI coding agents working on this Neovim configuration repository. The agent’s goal is to **simplify, refactor, and clean up** the config without breaking existing behavior, preserving key mappings, plugin functionality, startup behavior, etc.

## Project Structure

- `init.lua` or `init.vim` (entry point)
- `lua/` — Lua modules (core settings, utilities, plugin configurations)
- `ftplugin/` — filetype-specific settings
- Plugin manager files (e.g. `lazy.nvim` specs, etc.)
- Lockfiles (e.g. `lazy-lock.json` or equivalent)

## Setup & Dependencies

- Running Neovim ≥ **0.9** assumed.
- Necessary tools: **StyLua**, **Luacheck** (for linting), `nvim --headless` (for headless checks), `:checkhealth`.
- Plugin manager already installed; don’t change plugin manager unless explicitly authorized.

## Build / Test & Validation Commands

These actions must pass before any refactoring is considered successful:

- Headless load: `nvim --headless +q` (should exit cleanly, no errors)
- `:checkhealth` run headlessly, capturing output, and compare before & after.
- Startup time measurement:  
    `nvim --headless --startuptime after_user.log +q` vs baseline.
- Formatting: run `stylua .` should exit clean.
- Linting: `luacheck lua/**/*.lua` (allowing `vim` global).

## Style & Conventions

- Formatting: Use **StyLua**, consistent indentation, quote style, width limit (e.g., 80-100 columns depending on your preference).
- Modules: `require()` usage should respect module boundaries. Top-level heavy requires should be deferred if possible.
- Key mappings & autocmd setups must retain existing key combinations ‒ do not reassign unless requested.
- Shared helpers go into `lua/utils/`. Use consistent naming (snake_case or whatever already in use).
- Avoid duplication: if code is repeated, extract into module/helper.

## Refactoring / Behavior Preservation Rules

- ALWAYS preserve plugin functionality: plugin setup, lazy loading triggers, etc.
- NEVER drop user key mappings without explicit confirmation.
- Back up original config before refactoring (branch or file copies).
- For any change, validate by running the test commands.

## Workflow Expectations

- Work in incremental batches. Each batch should:
  1. Make limited changes (one module or subsystem)
  2. Validate via test commands
  3. Commit changes with clear message (e.g. `refactor(core): move options into core/options.lua`)

- Pull request includes: before/after file tree (or summary), before/after startup time & health.

## Version / Safety Considerations

- Do not delete plugin lockfiles unless refactoring commands explicitly request them.
- Provide compatibility shims if changing module exports or commands used elsewhere.
- Document any public APIs/modules that might be consumed in non-core parts.

## Excluded / Off-Limits Areas

- Do not modify external dependencies or plugin internals.
- Do not change Neovim API usage unless for modernization (but only with safety checks).
- Avoid OS-specific paths or hard-coding user home paths.

## Critical Notes

- If any test fails (startup errors, health check adding errors, key mapping broken, etc.), revert that batch.
- Monitor performance: ensure startup time not degraded.

## Style Guide References

- Link to `stylua.toml` (if exists) for formatting rules.
- Link to `.luacheckrc` or similar for linting rules.


--- Utility modules
--- Centralized access to all utility functions

local M = {}

-- Load utility modules
M.fs = require("utils.fs")
M.module = require("utils.module")
M.notify = require("utils.notify")

-- Convenience aliases for commonly used functions
M.file_exists = M.fs.file_exists
M.safe_require = M.module.safe_require
M.info = M.notify.info
M.warn = M.notify.warn
M.error = M.notify.error

return M
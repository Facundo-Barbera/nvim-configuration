local M = {}

--- Check if nvim-tree is open and visible
--- @return boolean
local function is_nvim_tree_open()
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local buf = vim.api.nvim_win_get_buf(win)
		local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
		if ft == "NvimTree" then
			return true
		end
	end
	return false
end

--- Check if there are any normal buffers open (excluding nvim-tree, help, etc.)
--- @return boolean
local function has_normal_buffers()
	local normal_buffers = 0
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_loaded(buf) then
			local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
			local bt = vim.api.nvim_get_option_value("buftype", { buf = buf })

			-- Count only normal file buffers
			if
				ft ~= "NvimTree"
				and ft ~= "help"
				and ft ~= "qf"
				and ft ~= "quickfix"
				and ft ~= "trouble"
				and ft ~= "TelescopePrompt"
				and ft ~= "startup"
				and bt ~= "nofile"
				and bt ~= "help"
				and bt ~= "quickfix"
				and bt ~= "terminal"
				and vim.api.nvim_buf_get_name(buf) ~= "" -- Exclude empty buffers
			then
				normal_buffers = normal_buffers + 1
			end
		end
	end
	return normal_buffers > 0
end

--- Show tree with standard behavior
local function show_tree()
	-- Simply open nvim-tree
	vim.cmd("NvimTreeOpen")
end

--- Custom buffer delete function
--- @param force boolean Whether to force delete
local function smart_buffer_delete(force)
	local current_buf = vim.api.nvim_get_current_buf()
	local buf_name = vim.api.nvim_buf_get_name(current_buf)

	-- Don't apply custom logic to special buffers
	local ft = vim.api.nvim_get_option_value("filetype", { buf = current_buf })
	if ft == "NvimTree" or ft == "help" or ft == "qf" or ft == "quickfix" then
		if force then
			vim.cmd("bdelete!")
		else
			vim.cmd("bdelete")
		end
		return
	end

	-- Delete the buffer
	if force then
		vim.cmd("bdelete!")
	else
		vim.cmd("bdelete")
	end

	-- Check if this was the last normal buffer
	if not has_normal_buffers() then
		-- If nvim-tree is closed/hidden, show tree
		if not is_nvim_tree_open() then
			show_tree()
		end
	end
end

--- Custom quit function that handles the tree properly
local function smart_quit()
	if not has_normal_buffers() then
		-- No normal buffers, just quit
		vim.cmd("quit")
	else
		-- Close current window, let normal quit behavior handle it
		vim.cmd("quit")
	end
end

--- Setup buffer management
function M.setup()
	-- Create user commands for smart buffer management
	vim.api.nvim_create_user_command("SmartBDelete", function()
		smart_buffer_delete(false)
	end, { desc = "Smart buffer delete that reopens tree when needed" })

	vim.api.nvim_create_user_command("SmartBDeleteForce", function()
		smart_buffer_delete(true)
	end, { desc = "Smart buffer force delete that reopens tree when needed" })

	-- Override default buffer delete commands with our smart versions
	vim.keymap.set("n", "<leader>bd", ":SmartBDelete<CR>", {
		desc = "Delete buffer (smart)",
		silent = true,
	})

	vim.keymap.set("n", "<leader>bD", ":SmartBDeleteForce<CR>", {
		desc = "Force delete buffer (smart)",
		silent = true,
	})

	-- Also handle :bd and :bdelete commands
	vim.api.nvim_create_user_command("Bd", function(opts)
		if opts.bang then
			smart_buffer_delete(true)
		else
			smart_buffer_delete(false)
		end
	end, { bang = true, desc = "Smart buffer delete" })
end

return M

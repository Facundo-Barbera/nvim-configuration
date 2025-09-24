-- Enhanced spell checking configuration
-- Smart multi-language Vim spell checker with auto-detection

local M = {}

local personal_spell_dir = vim.fn.stdpath("config") .. "/spell"
local personal_spell_file = personal_spell_dir .. "/personal.utf-8.add"
local data_spell_dir = vim.fn.stdpath("data") .. "/site/spell"
local spanish_spell_files = {
	{
		filename = "es.utf-8.spl",
		path = data_spell_dir .. "/es.utf-8.spl",
		url = "https://ftp.nluug.nl/vim/runtime/spell/es.utf-8.spl",
	},
	{
		filename = "es.utf-8.sug",
		path = data_spell_dir .. "/es.utf-8.sug",
		url = "https://ftp.nluug.nl/vim/runtime/spell/es.utf-8.sug",
	},
}

local text_filetypes = {
	"markdown",
	"text",
	"gitcommit",
	"rst",
	"tex",
	"latex",
	"plaintex",
	"typst",
	"mail",
	"org",
	"asciidoc",
}

local ui_filetypes = {
	"help",
	"terminal",
	"dashboard",
	"packer",
	"fzf",
	"NeogitStatus",
	"checkhealth",
	"lazy",
	"mason",
	"lspinfo",
}

local text_filetype_set = {}
for _, ft in ipairs(text_filetypes) do
	text_filetype_set[ft] = true
end

local detection_cooldown_ns = 5e9 -- 5 seconds

vim.opt.spell = false
vim.opt.spelllang = { "en_us", "es" }
vim.opt.spellsuggest = "best,9"
vim.opt.spellfile = personal_spell_file

local function ensure_personal_spell_dir()
	if vim.fn.isdirectory(personal_spell_dir) == 0 then
		vim.fn.mkdir(personal_spell_dir, "p")
	end
end

ensure_personal_spell_dir()

local spellsuggest_available = true

local function is_valid_spell_file(path)
	if vim.fn.filereadable(path) == 0 then
		return false
	end
	local size = vim.fn.getfsize(path)
	return size ~= nil and size > 0
end

local function copy_file(src, dest)
	local ok, err = pcall(function()
		local data = vim.fn.readfile(src, "b")
		if not data or vim.tbl_isempty(data) then
			error("empty source file")
		end
		local dest_dir = vim.fn.fnamemodify(dest, ":h")
		if vim.fn.isdirectory(dest_dir) == 0 then
			vim.fn.mkdir(dest_dir, "p")
		end
		vim.fn.writefile(data, dest, "b")
	end)
	if not ok then
		return false, err
	end
	return is_valid_spell_file(dest)
end

local function find_bundled_spell_file(filename)
	local config_candidate = vim.fn.stdpath("config") .. "/spell/" .. filename
	if is_valid_spell_file(config_candidate) then
		return config_candidate
	end
	local runtime_files = vim.api.nvim_get_runtime_file("spell/" .. filename, false)
	for _, file in ipairs(runtime_files) do
		if is_valid_spell_file(file) then
			return file
		end
	end
	return nil
end

local function download_file(entry)
	local result = vim.system({ "curl", "-fsSL", "-o", entry.path, entry.url }):wait()
	if result.code ~= 0 then
		local message = result.stderr
		if not message or message == "" then
			message = string.format("curl exited with code %d", result.code)
		end
		return false, message
	end
	return true
end

local function ensure_spell_files(opts)
	opts = opts or {}
	if vim.fn.isdirectory(data_spell_dir) == 0 then
		vim.fn.mkdir(data_spell_dir, "p")
	end

	for _, entry in ipairs(spanish_spell_files) do
		local valid = is_valid_spell_file(entry.path)
		if opts.force or not valid then
			local source = find_bundled_spell_file(entry.filename)
			if source then
				local copied, err = copy_file(source, entry.path)
				if not copied then
					vim.notify(
						string.format("Failed to copy spell file %s: %s", entry.filename, err),
						vim.log.levels.WARN
					)
				else
					valid = true
				end
			end
		end

		if not valid then
			local ok, err = download_file(entry)
			if not ok then
				vim.notify(
					string.format("Failed to download Spanish spell file %s: %s", entry.filename, err),
					vim.log.levels.ERROR
				)
				return false
			end
			valid = is_valid_spell_file(entry.path)
		end

		if not valid then
			vim.notify(string.format("Spanish spell file %s is unavailable", entry.filename), vim.log.levels.ERROR)
			return false
		end
	end

	spellsuggest_available = true
	return true
end

local function clean_text(lines)
	local text = table.concat(lines, " "):lower()
	text = text:gsub("\\[%w*]+%{[^}]*%}", "")
	text = text:gsub("\\[%w*]+", "")
	text = text:gsub("\\%b()", "")
	text = text:gsub("\\%b[]", "")
	text = text:gsub("%$[^%$]*%$", "")
	text = text:gsub("%b{}", "")
	text = text:gsub("[\\&%_%^%$]+", " ")
	return text
end

local function count_word_occurrences(text, words, weight)
	local score = 0
	for _, word in ipairs(words or {}) do
		local _, matches = text:gsub("%f[%w]" .. word .. "%f[%W]", "")
		score = score + matches * weight
	end
	return score
end

local function count_pattern_occurrences(text, patterns, weight)
	local score = 0
	for _, pattern in ipairs(patterns or {}) do
		local _, matches = text:gsub(pattern, "")
		score = score + matches * weight
	end
	return score
end

local spanish_indicators = {
	words = {
		"el",
		"la",
		"los",
		"las",
		"un",
		"una",
		"es",
		"son",
		"está",
		"están",
		"que",
		"para",
		"con",
		"por",
		"como",
		"en",
		"de",
		"del",
		"al",
		"se",
		"le",
		"lo",
		"pero",
		"muy",
		"también",
		"todo",
		"este",
		"esta",
		"cuando",
		"donde",
		"porque",
		"aunque",
		"desde",
		"hasta",
		"sobre",
		"entre",
		"después",
		"antes",
		"mientras",
		"siempre",
		"nunca",
		"aquí",
		"cómo",
		"cuál",
		"quién",
		"respuesta",
		"problema",
		"ejercicio",
		"solución",
		"matemáticas",
		"división",
		"fracción",
	},
	accents = { "á", "é", "í", "ó", "ú", "ñ", "ü" },
	patterns = { "ción", "sión", "dad", "tad", "mente", "ando", "endo" },
}

local english_indicators = {
	words = {
		"the",
		"and",
		"is",
		"are",
		"was",
		"were",
		"have",
		"has",
		"had",
		"will",
		"would",
		"could",
		"should",
		"this",
		"that",
		"these",
		"those",
		"with",
		"from",
		"they",
		"them",
		"their",
		"there",
		"where",
		"when",
		"what",
		"who",
		"how",
		"why",
		"because",
		"although",
		"however",
		"therefore",
		"while",
		"during",
		"after",
		"before",
		"always",
		"never",
		"here",
		"very",
		"also",
		"only",
		"just",
		"more",
		"most",
		"some",
		"any",
		"answer",
		"problem",
		"exercise",
		"solution",
		"mathematics",
		"division",
		"fraction",
	},
	patterns = { "ing", "tion", "ness", "ment", "able", "ible" },
}

local function detect_language_from_buffer()
	local total_lines = vim.api.nvim_buf_line_count(0)
	local end_line = math.min(total_lines, 100)
	local lines = vim.api.nvim_buf_get_lines(0, 0, end_line, false)
	if #lines == 0 then
		return "es"
	end

	local text = clean_text(lines)
	local spanish_score = count_word_occurrences(text, spanish_indicators.words, 2)
	spanish_score = spanish_score + count_pattern_occurrences(text, spanish_indicators.patterns, 1)
	spanish_score = spanish_score + count_pattern_occurrences(text, spanish_indicators.accents, 3)

	local english_score = count_word_occurrences(text, english_indicators.words, 2)
	english_score = english_score + count_pattern_occurrences(text, english_indicators.patterns, 1)

	-- Debug info for language detection (silent)
	local filetype = vim.bo.filetype
	if filetype == "tex" or filetype == "latex" or filetype == "plaintex" then
		-- Only log to internal debug, no user notification
		vim.notify_once(
			string.format("LaTeX language detection: Spanish=%d, English=%d", spanish_score, english_score),
			vim.log.levels.DEBUG
		)
	end

	if spanish_score > english_score and spanish_score > 3 then
		return "es"
	end

	if english_score > spanish_score and english_score > 3 then
		return "en_us"
	end

	-- If scores are low or tied, preserve current language instead of defaulting to Spanish
	local current_lang = vim.opt_local.spelllang:get()[1] or "en_us"
	return current_lang
end

local function set_spell_language(lang, manual)
	if lang == "es" and not ensure_spell_files() then
		vim.notify("Could not download Spanish spell files, using English", vim.log.levels.WARN)
		lang = "en_us"
	end

	vim.opt_local.spelllang = lang

	-- Track manual overrides to prevent auto-detection from changing them
	if manual then
		vim.b.spell_manual_override = lang
		vim.b.spell_manual_override_time = vim.loop.hrtime()
	end
end

local function auto_detect_language()
	-- Respect manual overrides for 30 minutes
	local manual_override_duration = 30 * 60 * 1e9 -- 30 minutes in nanoseconds
	local manual_override_time = vim.b.spell_manual_override_time or 0
	local now = vim.loop.hrtime()

	if manual_override_time > 0 and (now - manual_override_time) < manual_override_duration then
		-- Don't auto-detect if user manually set language recently
		return
	end

	local detected = detect_language_from_buffer()
	set_spell_language(detected)
end

local function show_spell_suggestions()
	if not vim.opt_local.spell:get() then
		return
	end

	local word = vim.fn.expand("<cword>")
	if word == "" then
		return
	end

	local is_misspelled = vim.fn.spellbadword(word)[1]
	if not is_misspelled then
		return
	end

	if not spellsuggest_available then
		return
	end

	local ok, suggestions = pcall(vim.fn.spellsuggest, word, 9)
	if not ok then
		local ensured = ensure_spell_files({ force = true })
		if ensured then
			spellsuggest_available = true
			-- Spanish spell files refreshed silently
		else
			spellsuggest_available = false
			vim.notify_once("Spell suggestions disabled: " .. tostring(suggestions), vim.log.levels.WARN)
		end
		return
	end
	if #suggestions > 0 then
		vim.diagnostic.open_float(nil, {
			scope = "cursor",
			header = "Spelling Suggestions for '" .. word .. "'",
			source = "vim-spell",
			focusable = false,
			close_events = { "CursorMoved", "CursorMovedI", "InsertCharPre" },
		})
	end
end

local function with_buf(bufnr, callback)
	if not vim.api.nvim_buf_is_valid(bufnr) then
		return
	end
	vim.api.nvim_buf_call(bufnr, callback)
end

local function setup_spell_keymaps()
	local function toggle_spell()
		vim.opt_local.spell = not vim.opt_local.spell:get()
		local status = vim.opt_local.spell:get() and "enabled" or "disabled"
		-- Spell checking status changed silently
	end

	local function force_download()
		for _, entry in ipairs(spanish_spell_files) do
			if vim.fn.filereadable(entry.path) == 1 then
				vim.fn.delete(entry.path)
			end
		end
		local ok = ensure_spell_files({ force = true })
		if ok then
			-- Spanish spell files refreshed silently
		end
	end

	local keymaps = {
		{ "n", "<leader>ss", toggle_spell, { desc = "Toggle spell checking" } },
		{
			"n",
			"<leader>se",
			function()
				set_spell_language("en_us", true)
			end,
			{ desc = "Set spell language to English" },
		},
		{
			"n",
			"<leader>sx",
			function()
				set_spell_language("es", true)
			end,
			{ desc = "Set spell language to Spanish" },
		},
		{
			"n",
			"<leader>sd",
			function()
				-- Clear manual override and force re-detection
				vim.b.spell_manual_override = nil
				vim.b.spell_manual_override_time = nil
				auto_detect_language()
			end,
			{ desc = "Auto-detect spell language" },
		},
		{ "n", "]s", "]s", { desc = "Next spelling error" } },
		{ "n", "[s", "[s", { desc = "Previous spelling error" } },
		{
			"n",
			"<leader>z=",
			function()
				local word = vim.fn.expand("<cword>")
				if word == "" then
					vim.notify("No word under cursor", vim.log.levels.WARN)
					return
				end

				local suggestions = vim.fn.spellsuggest(word, 10)
				if #suggestions == 0 then
					-- No spelling suggestions found (silent)
					return
				end

				vim.ui.select(suggestions, { prompt = "Spelling suggestions for '" .. word .. "':" }, function(choice)
					if choice then
						vim.cmd("normal! ciw" .. choice)
						vim.cmd("normal! b")
					end
				end)
			end,
			{ desc = "Spelling suggestions (enhanced)" },
		},
		{ "n", "zg", "zg", { desc = "Add word to dictionary" } },
		{ "n", "zw", "zw", { desc = "Mark word as wrong" } },
		{ "n", "zug", "zug", { desc = "Remove word from dictionary" } },
		{
			"n",
			"<leader>sl",
			function()
				vim.cmd("spellgood")
				-- Spelling checked on current line silently
			end,
			{ desc = "Spell check current line" },
		},
		{ "n", "<leader>sD", force_download, { desc = "Force download spell files" } },
		{ "n", "<leader>s?", show_spell_suggestions, { desc = "Show spelling suggestions" } },
	}

	for _, map in ipairs(keymaps) do
		vim.keymap.set(map[1], map[2], map[3], map[4])
	end
end

local function schedule_detection(bufnr, delay)
	vim.defer_fn(function()
		with_buf(bufnr, function()
			if not vim.opt_local.spell:get() then
				return
			end
			auto_detect_language()
		end)
	end, delay)
end

local function setup_autocmds()
	local group = vim.api.nvim_create_augroup("SpellConfig", { clear = true })

	vim.api.nvim_create_autocmd("FileType", {
		group = group,
		pattern = text_filetypes,
		desc = "Enable spell checking and auto-detect language for text filetypes",
		callback = function(args)
			with_buf(args.buf, function()
				vim.opt_local.spell = true
				schedule_detection(args.buf, 500)
			end)
		end,
	})

	vim.api.nvim_create_autocmd("FileType", {
		group = group,
		pattern = ui_filetypes,
		desc = "Disable spell checking for UI filetypes",
		callback = function(args)
			with_buf(args.buf, function()
				vim.opt_local.spell = false
			end)
		end,
	})

	vim.api.nvim_create_autocmd("TextChanged", {
		group = group,
		pattern = "*",
		desc = "Auto-detect language on text changes",
		callback = function(args)
			if not vim.api.nvim_buf_is_valid(args.buf) then
				return
			end

			local ft = vim.bo[args.buf].filetype
			if not text_filetype_set[ft] then
				return
			end

			with_buf(args.buf, function()
				if not vim.opt_local.spell:get() then
					return
				end

				local now = vim.loop.hrtime()
				local last = vim.b.last_spell_check or 0
				if now - last <= detection_cooldown_ns then
					return
				end

				vim.b.last_spell_check = now
				auto_detect_language()
			end)
		end,
	})

	vim.api.nvim_create_autocmd("CursorHold", {
		group = group,
		pattern = "*",
		desc = "Show spelling suggestions on hover",
		callback = function(args)
			with_buf(args.buf, function()
				if vim.opt_local.spell:get() then
					show_spell_suggestions()
				end
			end)
		end,
	})
end

function M.setup()
	if M._configured then
		return
	end
	M._configured = true

	setup_spell_keymaps()
	setup_autocmds()

	vim.defer_fn(function()
		ensure_spell_files()
	end, 1000)
end

M.detect_language = detect_language_from_buffer
M.set_language = set_spell_language
M.auto_detect = auto_detect_language

M.setup()

return M

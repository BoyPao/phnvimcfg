-- License: GPL-3.0-or-later
-- Copyright (c) 2026 Peng Hao <635945005@qq.com>

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = ","
vim.g.maplocalleader = "\\"
local snopts = { silent = true, noremap = true }
local esnopts = { silent = true, noremap = true, expr = true }
local my_opts = {
	override_pickers_telescope = true,
}


-- Plug Mgr Config -----------------------------------------------------------------------------------------------------
-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

-- Setup lazy.nvim
require("lazy").setup({
	spec = {
		-- add your plugins here
		{
			"catppuccin/nvim", name = "catppuccin", priority = 1000
		},
		{
			"akinsho/bufferline.nvim",
			version = "*",
			dependencies = 'nvim-tree/nvim-web-devicons',
			after = "catppuccin",
			config = function()
				require("bufferline").setup {
					highlights = require("catppuccin.special.bufferline").get_theme()
				}
			end
		},
		{
			"olimorris/codecompanion.nvim",
			version = "^19.0.0",
			dependencies = {
				"nvim-lua/plenary.nvim",
				"nvim-treesitter/nvim-treesitter",
			},
			opts = {},
		},
		{
			'neoclide/coc.nvim', branch = 'release',
			lazy = true, -- this and below config is for setup race error msg
			config = function()
				require("codecompanion.providers.completion.coc.setup")
				vim.g.coc_global_extensions = {
					'coc-json', 'coc-git', 'coc-clangd', 'coc-cmake', 'coc-copilot', 'coc-lua',
					'coc-sh', 'coc-xml',
				}
			end,
		},
		{
			'MeanderingProgrammer/render-markdown.nvim',
			-- if you prefer nvim-web-devicons
			dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' },
			-- config from codecompanion
			ft = { "markdown", "codecompanion" },
			opts = {},
		},
		{
			"iamcco/markdown-preview.nvim",
			cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
			build = function() vim.fn["mkdp#util#install"]() end,
			ft = { "markdown" },
			init = function()
				vim.g.mkdp_filetypes = { "markdown" }
				vim.g.mkdp_browser = 'firefox'
			end,
		},
		{
			"dhananjaylatkar/cscope_maps.nvim",
			dependencies = {
				"nvim-telescope/telescope.nvim", -- optional [for picker="telescope"]
			},
			opts = {},
			config = function()
				if not my_opts.override_pickers_telescope then return end

				-- override pickers.telescope to apply more highlights to result window
				package.loaded["cscope.pickers.telescope"] = (function()
					local pickers = require("telescope.pickers")
					local finders = require("telescope.finders")
					local config = require("telescope.config")
					local utils = require("telescope.utils")
					local cs_utils = require("cscope_maps.utils")

					local entry_maker = function(entry)
						return {
							value = entry,
							display = function()
								local display_filename = cs_utils.get_rel_path(
									vim.fn.getcwd(), entry["filename"])
								local coordinates = string.format(":%s:", entry["lnum"])
								local display, hl_group, icon =
								utils.transform_devicons(
									entry["filename"],
									display_filename .. coordinates .. entry["text"],
									false
								)

								local highlights = {}
								local offset = 0
								if hl_group then
									table.insert(highlights,
									{ { offset, offset + #icon }, hl_group })
								end

								-- apply hl group for filename, lnum
								offset = offset + #icon + 1
								table.insert(highlights,
								{ { offset, offset + #display_filename },
								"TelescopeResultsIdentifier"})

								offset = offset + #display_filename
								table.insert(highlights,
								{ { offset, offset + #coordinates },
								"TelescopeResultsLineNr"})

								return display, highlights
							end,
							ordinal = entry["filename"] .. entry["text"],
							path = cs_utils.get_abs_path(entry["filename"]),
							lnum = tonumber(entry["lnum"]),
						}
					end

					local M = {}
					M.run = function(opts)
						opts = opts or {}
						opts.entry_maker = entry_maker
						local finder = finders.new_table({
							results = opts.cscope.parsed_output,
							entry_maker = entry_maker,
						})
						pickers.new(opts, {
							prompt_title = opts.cscope.prompt_title,
							finder = finder,
							previewer = config.values.grep_previewer(opts),
							sorter = config.values.generic_sorter(opts),
						}):find()
					end
					return M
				end)()
			end,
		},
		{
			'nvim-telescope/telescope.nvim', version = '*',
			dependencies = {
				'nvim-lua/plenary.nvim',
				-- optional but recommended
				{ 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
				'fannheyward/telescope-coc.nvim',
			}
		},
		{
			"nvim-tree/nvim-tree.lua",
			version = "*",
			lazy = false,
			dependencies = { "nvim-tree/nvim-web-devicons", },
			config = function()
				require("nvim-tree").setup {}
			end,
		},
		{
			'akinsho/toggleterm.nvim', version = "*", opts = { --[[ things you want to change go here]] }
		},
		{
			'nvim-lualine/lualine.nvim',
			dependencies = { 'nvim-tree/nvim-web-devicons' },
		},
		{
			'BoyPao/mhl'
		},
	},
	-- Configure any other settings here. See the documentation for more details.
	-- colorscheme that will be used when installing plugins.
	install = { colorscheme = { "habamax" } },
	-- automatically check for plugin updates
	checker = { enabled = true },
})

-- Plug Config ---------------------------------------------------------------------------------------------------------
-- catppuccin config
require("catppuccin").setup({
	custom_highlights = function(colors)
		local darken = require("catppuccin.utils.colors").darken
		local lighten = require("catppuccin.utils.colors").lighten
		local brighten = require("catppuccin.utils.colors").brighten
		local inc_sat = require("catppuccin.utils.colors").increase_saturation
		return {
			Comment = { fg = darken(colors.green, 0.90) },
			String = { fg = colors.peach },
			Macro = { fg = colors.mauve },
			PreProc = { link = 'Macro'},
			Include = { fg = colors.lavender },
			Special = { fg = colors.red },
			Number = { fg = colors.yellow },
			Function = { fg = colors.yellow },
			Identifier = { fg = lighten(colors.blue, 0.70) },
			Tag = { fg = colors.teal },
			Constant = { fg = colors.sapphire },
			Character = { fg = darken(colors.blue, 0.90) },
			Boolean = { link = 'Character' },
			Type = { link = 'Character' },
			StorageClass = { link = 'Character' },
			Structure = { link = 'Character' },

			Label = { fg = inc_sat(colors.pink, 0.25) },
			Conditional = { link = 'Label' },
			Repeat = { link = 'Label' },
			Statement = { link = 'Label' },
			Operator = { link = 'Label' },
			Exception = { link = 'Label' },
			Keyword = { link = 'Label' },

			Search = { bg = darken(colors.sky, 0.38), fg = colors.test },
			IncSearch = { bg = darken(colors.sky, 0.60), fg = colors.text },
			CurSearch = { link = 'IncSearch' },

			Todo = { bg = colors.green, fg = colors.base, style = { "bold" } },
			WarningMsg = { fg = colors.mantle, bg = colors.yellow, style = { "bold" } },
			ErrorMsg = { fg = colors.mantle, bg = colors.red, style = { "bold" } },

			["@variable"] = { link = 'Identifier' },
			["@variable.builtin"] = { link = 'Special' },
			["@variable.member"] = { link = 'Identifier' },
			["@variable.parameter"] = { link = 'Identifier' },
			["@keyword.type"] = { link = 'Type' },
			["@keyword.modifier"] = { link = 'Type' },
			["@type.builtin"] = { link = 'Type' },
			["@property"] = { link = 'Identifier' },
			["@function.builtin"] = { link = 'Function' },
			["@function.macro"] = { link = 'Macro' },
			["@keyword.function"] = { link = 'Keyword' },
			["@keyword.operator"] = { link = 'Keyword' },
			["@keyword.return"] = { link = 'Keyword' },
			["@keyword.export"] = { link = 'Keyword' },
			["@keyword.import.c"] = { link = 'Include' },
			["@keyword.import.cpp"] = { link = 'Include' },
			["@module"] = { fg = colors.teal },
			["@constructor"] = { fg = colors.teal },
			["@comment.todo"] = { link = 'Todo' },
			["@text.todo"] = { link = 'Todo' },

			CocSemTypeEnumMember = { link = "Constant" },

			TelescopeSelection = { fg = 'None', bg = colors.surface0, style = { "bold" }, },
			TelescopeSelectionCaret = { fg = colors.peach, bg = colors.surface0, style = { "bold" }, },
			TelescopeMatching = { fg = colors.yellow, style = { "bold" }, },

			TelescopeResultsLineNr = { link = 'Label' },
			TelescopeResultsIdentifier = { link = 'Identifier' },
			TelescopeResultsNumber = { link = 'Number' },
			TelescopeResultsComment = { link = 'Comment' },
			TelescopeResultsSpecialComment = { link = 'SpecialComment' },
		}
	end,
	integrations = {
		cmp = true,
		gitsigns = true,
		nvimtree = true,
		notify = false,
		coc_nvim = true,
		render_markdown = true,
		telescope = {
			enabled = true,
		},
		mini = {
			enabled = true,
			indentscope_color = "",
		},
	},
})
vim.cmd('silent! colorscheme catppuccin-nvim')

-- nvim-treesitter config
require('nvim-treesitter').setup {
	-- Directory to install parsers and queries to (prepended to `runtimepath` to have priority)
	install_dir = vim.fn.stdpath('data') .. '/site'
}
require('nvim-treesitter').install {
	'bash', 'c', 'cpp', 'devicetree', 'json', 'lua', 'make', 'markdown', 'python', 'xml'
}
vim.keymap.set('n', '<leader>h', ':Inspect<CR>', { noremap = true, silent = true })

-- bufferline
vim.opt.termguicolors = true
vim.keymap.set('n', '<C-Right>', ':BufferLineCycleNext<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<C-Left>', ':BufferLineCyclePrev<CR>', { noremap = true, silent = true })

-- codecompanion config
require('codecompanion').setup {
	adapters = {
		http = {
			openai = function()
				return require("codecompanion.adapters").extend("openai", {
					url = os.getenv("OPENAI_URL"),
					env = {
						api_key = "OPENAI_API_KEY",
					},
				})
			end,
		},
	},
	interactions = {
		chat = {
			adapter = {
				name = "openai",
				model = os.getenv("OPENAI_MODEL_CHAT"),
			},
			opts = {
				completion_provider = "coc", -- blink|cmp|coc|default
			},
		},
		cli = {
			agent = "claude_code",
			agents = {
				claude_code = {
					cmd = os.getenv("CLAUDE_CLI_CMD"),
					args = {},
					description = "Claude Code CLI",
					provider = "terminal",
				},
			},
		},
	},
	display = {
		chat = {
			window = {
				layout = "vertical", -- float|vertical|horizontal|tab|buffer
				full_height = true, -- for vertical layout
				position = "right",
				width = 0.4, ---@return number|fun(): number
			},
		},
	},
	-- NOTE: The log_level is in `opts.opts`
	opts = {
		log_level = "DEBUG",
	},
}
vim.keymap.set({ "n", "v" }, "<C-a>", "<cmd>CodeCompanionActions<cr>", { noremap = true, silent = true })
vim.keymap.set({ "n", "v" }, "<Leader>a1", "<cmd>CodeCompanionCLI ><cr>", { noremap = true, silent = true })
vim.keymap.set({ "n", "v" }, "<Leader>a2", "<cmd>CodeCompanionChat Toggle<cr>", { noremap = true, silent = true })
vim.keymap.set("v", "ga", "<cmd>CodeCompanionChat Add<cr>", { noremap = true, silent = true })
-- Expand 'cc' into 'CodeCompanion' in the command line
vim.cmd([[cab cc CodeCompanion]])

-- coc config
require("lazy").load({ plugins = { "coc.nvim" } })
vim.opt.updatetime = 300
vim.opt.signcolumn = "yes"
function _G.check_back_space()
	local col = vim.fn.col('.') - 1
	return col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') ~= nil
end
vim.keymap.set(
	"i", "<TAB>", 'coc#pum#visible() ? coc#pum#next(1) : v:lua.check_back_space() ? "<TAB>" : coc#refresh()', esnopts)
vim.keymap.set("i", "<S-TAB>", [[coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"]], esnopts)
function PopupKeyRemap(k)
	if vim.fn['coc#pum#visible']() == 1 then
		vim.fn['coc#pum#stop']()
	end

	if k == 'u' then
		return "<Up>"
	elseif k == 'd' then
		return "<Down>"
	elseif k == 'e' then
		return "<Enter>"
	end

	return ""
end
vim.keymap.set("i", "<Up>",    function() return PopupKeyRemap('u') end, esnopts)
vim.keymap.set("i", "<Down>",  function() return PopupKeyRemap('d') end, esnopts)
vim.keymap.set("i", "<Entry>", function() return PopupKeyRemap('e') end, esnopts)
vim.keymap.set("n", "zg", function()
	require('telescope').extensions.coc.definitions({})
end, { silent = true, desc = 'zg:lsp' } )
vim.keymap.set("n", "zc", function()
	require('telescope').extensions.coc.references_used({})
end, { silent = true, desc = 'zc:lsp' } )
vim.keymap.set("n", "zi", function()
	require('telescope').extensions.coc.implementations({})
end, { silent = true, desc = 'zi:lsp' } )
vim.keymap.set("n", "zh", function()
	require('telescope').extensions.coc.declarations({})
end, { silent = true, desc = 'zh:lsp' } )
vim.keymap.set("n", "<C-t>", "<C-o>", { silent = true } )

-- telescope config
local builtin = require('telescope.builtin')
vim.keymap.set('n', 'ff', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', 'fg', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', 'fb', builtin.current_buffer_fuzzy_find, { desc = 'Telescope buffers' })
--vim.keymap.set('n', 'fb', builtin.buffers, { desc = 'Telescope buffers' })
--vim.keymap.set('n', 'fh', builtin.help_tags, { desc = 'Telescope help tags' })
vim.keymap.set('n', 'zt', function()
	local word_under_cursor = vim.fn.expand('<cword>')
	require('telescope.builtin').grep_string({ search = word_under_cursor })
end)
require('telescope').setup({
	defaults = {
		layout_config = {
			width = 0.95,
			horizontal = {
				results_width = 0.7,
				preview_width = 0.3,
			},
		},
		scroll_strategy = "limit",
	},
	extensions = {
		coc = {
			prefer_locations = false, -- single result jumps directly, true forces telescope always
			push_cursor_on_edit = true, -- save the cursor position to jump back in the future
			timeout = 3000, -- timeout for coc commands
		}
	},
})
require('telescope').load_extension('fzf')
require('telescope').load_extension('coc')

-- cscope_maps config
local function FindDBDir()
	local cwd = vim.fn.getcwd()
	local root = ''
	local markers = { 'cscope.out', 'GTAGS' }
	for _, marker in ipairs(markers) do
		local found = vim.fn.findfile(marker, '.;')
		if found ~= '' then
			root = root .. vim.fn.fnamemodify(vim.fn.fnamemodify(found, ':h'), ':p')
			break
		end
	end
	if root == '' then
		root = cwd
	end
	return root
end
require("cscope_maps").setup({
	cscope = {
		db_file = FindDBDir() .. "/cscope.out::@", -- DB or table of DBs
		exec = "cscope", -- "cscope" or "gtags-cscope"
		picker = "telescope", -- "quickfix", "location", "telescope", "fzf-lua", "mini-pick" or "snacks"
		skip_picker_for_single_result = true, -- "false" or "true"
		db_build_cmd = { script = "default", args = { "-bqkv", "-i", "cscope.tags.lst" } },
		statusline_indicator = nil,
		project_rooter = {
			enable = false, -- not find root, cause we find root ourself
			change_cwd = false, -- not change cwd, otherwise sometime db not work
		},
	},
})
local function GenerateLst()
	local lst = 'cscope.tags.lst'
	local tar = {
		c   = '.h .c',
		cpp = '.hpp .cpp .cc',
		mk  = 'Makefile Kconfig .mk',
		dts = '.dtsi .dts',
	}

	local cmd = { "find", ".", "-type", "f" }
	local first = true
	for _, value in pairs(tar) do
		for item in value:gmatch("%S+") do
			if not first then table.insert(cmd, "-o") end
			table.insert(cmd, "-name")
			table.insert(cmd, item:sub(1, 1) == '.' and ('*' .. item) or item)
			first = false
		end
	end

	local job = vim.system(cmd)
	local rt = job:wait()
	if rt.code == 0 then
		local lines = vim.split(rt.stdout, "\n", { plain = true, trimempty = true })
		vim.fn.writefile(lines, lst)
	end

	return rt
end

vim.keymap.set("n", "22", function ()
	local root = FindDBDir()
	vim.cmd("cd " .. vim.fn.fnameescape(root))
	local rt = GenerateLst()
	if rt.code == 0 then
		vim.cmd("Cs db build")
		vim.cmd("Cs reload")
		vim.cmd("cd ..")
	else
		print("Error: " .. rt.stderr)
	end
end, snopts)
-- default: use coc + clangd for jump, use '11' to switch to cscope
--vim.keymap.set("n", "zg", "<cmd>Cs f g<cr>", { silent = true, noremap = true, desc="zg:cscope"})
--vim.keymap.set("n", "zc", "<cmd>Cs f c<cr>", { silent = true, noremap = true, desc="zc:cscope"})
--vim.keymap.set("n", "zi", "<cmd>Cs f i<cr>", { silent = true, noremap = true, desc="zi:cscope"})
vim.keymap.set("n", "zf", "<cmd>Cs f f<cr>", { silent = true, noremap = true, desc="zf:cscope" })
vim.keymap.set("n", "zs", "<cmd>Cs f s<cr>", { silent = true, noremap = true, desc="zs:cscope" })
vim.keymap.set("n", "za", "<cmd>Cs f a<cr>", { silent = true, noremap = true, desc="za:cscope" })

-- nvim-tree config
vim.keymap.set('n', 'kk', ':NvimTreeToggle<CR>', snopts)
vim.keymap.set('n', 'll', ':NvimTreeFindFile<CR>', snopts)
require("nvim-tree").setup({
	renderer = {
		group_empty = true,  -- empty dir will be group
	},
	filters = {
		git_ignored = false;
		dotfiles = false;
	},
	sort = {
		sorter = "case_sensitive",
	},
})
vim.api.nvim_create_autocmd('BufEnter', {
	pattern = '*',
	callback = function(args)
		pcall(vim.keymap.del, 'n', 'f', { buffer = args.buf })
		pcall(vim.keymap.del, 'n', 'F', { buffer = args.buf })
		pcall(vim.keymap.del, 'n', '<', { buffer = args.buf })
		pcall(vim.keymap.del, 'n', '>', { buffer = args.buf })
	end,
})

-- toggleterm config
function _G.set_terminal_keymaps()
	vim.keymap.set('t', 'qq', '<cmd>close<CR>', snopts)
	vim.keymap.set('t', '<C-n>', [[<C-\><C-n>]], snopts)
	vim.keymap.set('t', 'ww', [[<C-\><C-n><C-w>]], snopts)
	vim.keymap.set('t', "<<", "5<C-w><", snopts)
	vim.keymap.set('t', ">>", "5<C-w>>", snopts)
end
vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')

vim.keymap.set("n", "<C-p>", ":ToggleTerm direction=vertical<CR>", snopts)
vim.keymap.set("n", "<Leader><C-p>", ":ToggleTerm direction=horizontal<CR>", snopts)
require("toggleterm").setup{
	-- size can be a number or function which is passed the current terminal
	size = function(term)
		if term.direction == "horizontal" then
			return vim.o.lines * 0.2
		elseif term.direction == "vertical" then
			return vim.o.columns * 0.4
		end
	end,
	open_mapping = [[<c-\>]], -- or { [[<c-\>]], [[<c-¥>]] } if you also use a Japanese keyboard.
	on_open = function(term) -- function to run when the terminal opens
		vim.api.nvim_command('startinsert')
	end,
	hide_numbers = true, -- hide the number column in toggleterm buffers
	shade_filetypes = {},
	-- when neovim changes it current directory the terminal will change it's own when next it's opened
	autochdir = false,
	-- NOTE: this option takes priority over highlights specified so if you specify Normal highlights you should set this to false
	shade_terminals = true,
	shading_factor = '-30', -- the percentage by which to lighten dark terminal background, default: -30
	shading_ratio = '-3', -- the ratio of shading factor for light/dark terminal background, default: -3
	start_in_insert = true,
	insert_mappings = true, -- whether or not the open mapping applies in insert mode
	terminal_mappings = true, -- whether or not the open mapping applies in the opened terminals
	persist_size = true,
	persist_mode = true, -- if set to true (default) the previous terminal mode will be remembered
	close_on_exit = true, -- close the terminal window when the process exits
	clear_env = false, -- use only environmental variables from `env`, passed to jobstart()
	-- Change the default shell. Can be a string or a function returning a string
	shell = vim.o.shell,
	auto_scroll = true, -- automatically scroll to the bottom on terminal output
	-- This field is only relevant if direction is set to 'float'
	winbar = {
		enabled = false,
		name_formatter = function(term) --  term: Terminal
			return term.name
		end
	},
	responsiveness = {
		-- breakpoint in terms of `vim.o.columns` at which terminals will start to stack on top of each other
		-- instead of next to each other
		-- default = 0 which means the feature is turned off
		horizontal_breakpoint = 135,
	}
}

-- lualine config
require('lualine').setup({
	sections = {
		lualine_c = {
			{
				'filename',
				path = 2, -- 0:no path 1:show path based on nvim working path 2:abs path
				file_status = true,
			},
		},
	},
	inactive_sections = {
		lualine_c = {
			{
				'filename',
				path = 2, -- 0:no path 1:show path based on nvim working path 2:abs path
			},
		},
	},
})

-- mhl config
vim.keymap.set("n", "<Leader>m", ":MhlTriggerMatch<CR>", snopts)
vim.keymap.set("n", "<Leader>n", ":MhlClearAllMatch<CR>", snopts)

-- Other Self Config ---------------------------------------------------------------------------------------------------
vim.opt.mouse = ''		-- click+move will on visual mode, so disable mouse totally, use <Tab> to switch mouse
vim.opt.selectmode = mouse,key 	-- This allows select copy by mouse
vim.opt.number = true
vim.opt.cursorline = true
vim.opt.colorcolumn = "120" 	-- TODO: make it change
vim.opt.iskeyword:append("_", "@", "%")
vim.opt.listchars:append("tab:'``")
vim.opt.scrolloff = 7
vim.opt.cmdheight = 2  		-- always show at least 1 line message
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.shortmess:append("S") 	-- show "search hit BOTTOM, continuing at TOP" rather then "[1/5]"

vim.keymap.set("n", "<Leader><CR>", ":nohlsearch<CR>", snopts)
vim.keymap.set("n", "vv", ":vsplit<CR>", snopts)
vim.keymap.set("n", "ww", "<C-W>", snopts)
vim.keymap.set("n", "<<", "5<C-w><", snopts)
vim.keymap.set("n", ">>", "5<C-w>>", snopts)
vim.keymap.set("n", "++", "5<C-w>+", snopts)
vim.keymap.set("n", "--", "5<C-w>-", snopts)

local function range_sub(repl)
	local s, e = vim.fn.line("v"), vim.fn.line(".")
	if s == 0 then s = e end
	if s > e then s, e = e, s end
	vim.cmd(s .. "," .. e .. "s=^\\(//\\)*=" .. repl .. "=g")
	vim.cmd("noh")
end
vim.keymap.set({ "n", "v" }, "<F7>", function() range_sub("//") end, snopts)
vim.keymap.set({ "n", "v" }, "<F6>", function() range_sub("") end, snopts)

vim.keymap.set("c", ",rr", function()
	local word = vim.fn.expand("<cword>")
	local cmd = ".," .. "s/" .. word .. "//g" .. "<left><left>"
	return cmd
end, { expr = true, noremap = true })
function _G.RepeatOneLineReplace(cword)
	local cmd = vim.fn.getreg(':')

	if string.sub(cmd, 1, 4) == ".,s/" then
		local search_pattern = vim.fn.getreg('/')
		if cword ~= search_pattern then
			local found = vim.fn.search(search_pattern, 'W')
			if found == 0 then
				vim.notify("No more matches found.", vim.log.levels.WARN)
				return
			end
		end
		vim.cmd(":" .. cmd)
	end
end
vim.keymap.set("n", "<Leader>rr", function()
	local cword = vim.fn.expand("<cword>")
	_G.RepeatOneLineReplace(cword)
end, snopts)

local function get_code_jump_method(sym)
    for _, m in ipairs(vim.api.nvim_get_keymap('n')) do
        if m.desc and string.find(m.desc, sym, 1, true) then
		return string.gsub(m.desc, sym, "", 1)
	end
    end
end
vim.keymap.set("n", "11", function()
	local keys = { 'zg', 'zc', 'zi' }
	local method = { 'lsp', 'cscope' }
	local curr = get_code_jump_method(keys[1] .. ':')
	local next = method[1]
	if curr and curr == method[1] then
		next = method[2]
	end
	if next == method[1] then
		vim.keymap.set("n", keys[1], function()
			require('telescope').extensions.coc.definitions({})
		end, { silent = true, desc = keys[1] .. ':' .. next } )
		vim.keymap.set("n", keys[2], function()
			require('telescope').extensions.coc.references_used({})
		end,{ silent = true, desc = keys[2] .. ':' .. next } )
		vim.keymap.set("n", keys[3], function()
			require('telescope').extensions.coc.implementations({})
		end, { silent = true, desc = keys[3] .. ':' .. next } )
	else
		vim.keymap.set("n", keys[1], "<cmd>Cs f g<cr>",
		{ silent = true, noremap = true, desc = keys[1] .. ":" .. next})
		vim.keymap.set("n", keys[2], "<cmd>Cs f c<cr>",
		{ silent = true, noremap = true, desc = keys[2] .. ":" .. next})
		vim.keymap.set("n", keys[3], "<cmd>Cs f i<cr>",
		{ silent = true, noremap = true, desc = keys[3] .. ":" .. next})
	end
	vim.notify("code jump method change to: " .. next, vim.log.levels.INFO)
end, snopts)

vim.keymap.set("n", '<Tab>', function()
	local on = vim.o.mouse ~= ''
	local str
	if on then
		vim.opt.mouse = ''
		str = 'OFF'
	else
		vim.opt.mouse = 'n'
		str = 'ON: ' .. vim.o.mouse
	end
	vim.notify("mouse " .. str, vim.log.levels.INFO)
end, snopts)

vim.keymap.set("n", "<Leader>d", function() -- debug
	vim.system({"cscope", "show"}, { text = true }, function(obj)
		if obj.code == 0 then
			print("[SUCCESS] out:" .. obj.stdout .. " err:" .. obj.stderr .. " end")
		else
			print("[FAILED] out:" .. obj.stdout .. " err:" .. obj.stderr .. " end")
		end
	end)
end, snopts)

vim.api.nvim_set_hl(0, 'SpaceEOL', { bg='#45475a' })
vim.api.nvim_create_autocmd({'BufWritePost', 'InsertLeave', 'BufEnter'}, {
	callback = function()
		vim.cmd('match SpaceEOL /\\s\\+$/')
	end
})
vim.api.nvim_create_autocmd( 'BufWritePre', {
	callback = function()
		vim.cmd(':%s/\\s\\+$//ge')
	end
})

local group = vim.api.nvim_create_augroup("GotoBufHistoryLine", { clear = true })
vim.api.nvim_create_autocmd("BufReadPost", {
	group = group,
	pattern = "*",
	callback = function()
		local last_pos = vim.api.nvim_buf_get_mark(0, '"')
		local last_line = last_pos[1]
		local line_count = vim.api.nvim_buf_line_count(0)
		if last_line > 1 and last_line <= line_count then
			vim.cmd("normal! g`\"")
		end
	end,
})

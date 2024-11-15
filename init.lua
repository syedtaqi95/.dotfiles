--[[
Neovim config based on kickstart.nvim with my mods :)
-]]

-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Disable netrw as using alternative file explorer
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- [[ Install `lazy.nvim` plugin manager ]]
--    https://github.com/folke/lazy.nvim
--    `:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

-- [[ Configure plugins ]]
-- NOTE: Here is where you install your plugins.
--  You can configure plugins using the `config` key.
--
--  You can also configure plugins after the setup call,
--    as they will be available in your neovim runtime.
require('lazy').setup({
  -- NOTE: First, some plugins that don't require any configuration

  -- Git related plugins
  'tpope/vim-fugitive',
  'tpope/vim-rhubarb',
  {
    "rbong/vim-flog",
    lazy = true,
    cmd = { "Flog", "Flogsplit", "Floggit" },
    dependencies = {
      "tpope/vim-fugitive",
    },
  },

  -- Detect tabstop and shiftwidth automatically
  'tpope/vim-sleuth',

  -- NOTE: This is where your plugins related to LSP can be installed.
  --  The configuration is done below. Search for lspconfig to find it below.
  {
    -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',

      -- Useful status updates for LSP
      -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
      { 'j-hui/fidget.nvim', opts = {} },

      -- Additional lua configuration, makes nvim stuff amazing!
      'folke/neodev.nvim',
    },
  },

  -- Install typescript LSP separately due to some issues, e.g. go to source
  -- definition does not work with typescript-language-server
  {
    "pmizio/typescript-tools.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
    opts = {
      on_attach = function(_, bufnr)
        vim.keymap.set('n', 'gs', ':TSToolsGoToSourceDefinition<CR>',
          {
            buffer = bufnr,
            desc = 'LSP: [G]oto [S]ource Definition',
            silent = true,
          })
      end
    },
  },

  {
    "L3MON4D3/LuaSnip",
    build = "make install_jsregexp",
    -- config = function()
    --   -- LuaSnip configuration can go here
    -- end,
  },

  {
    -- Autocompletion
    'hrsh7th/nvim-cmp',
    dependencies = {
      -- Snippet Engine & its associated nvim-cmp source
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',

      -- Adds LSP completion capabilities
      'hrsh7th/cmp-nvim-lsp',

      -- Adds a number of user-friendly snippets
      'rafamadriz/friendly-snippets',
    },
  },

  -- Useful plugin to show you pending keybinds.
  {
    'folke/which-key.nvim',
    dependencies = {
      "echasnovski/mini.icons",
      'nvim-tree/nvim-web-devicons',
    },
    event = "VeryLazy",
    opts = {}
  },

  {
    -- Adds git related signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
    opts = {
      -- See `:help gitsigns.txt`
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map({ 'n', 'v' }, ']c', function()
          if vim.wo.diff then
            return ']c'
          end
          vim.schedule(function()
            gs.next_hunk()
          end)
          return '<Ignore>'
        end, { expr = true, desc = 'Jump to next hunk' })

        map({ 'n', 'v' }, '[c', function()
          if vim.wo.diff then
            return '[c'
          end
          vim.schedule(function()
            gs.prev_hunk()
          end)
          return '<Ignore>'
        end, { expr = true, desc = 'Jump to previous hunk' })

        -- Actions
        -- visual mode
        map('v', '<leader>hs', function()
          gs.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = 'stage git hunk' })
        map('v', '<leader>hr', function()
          gs.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = 'reset git hunk' })
        -- normal mode
        map('n', '<leader>hs', gs.stage_hunk, { desc = 'git stage hunk' })
        map('n', '<leader>hr', gs.reset_hunk, { desc = 'git reset hunk' })
        map('n', '<leader>hS', gs.stage_buffer, { desc = 'git Stage buffer' })
        map('n', '<leader>hu', gs.undo_stage_hunk, { desc = 'undo stage hunk' })
        map('n', '<leader>hR', gs.reset_buffer, { desc = 'git Reset buffer' })
        map('n', '<leader>hp', gs.preview_hunk, { desc = 'preview git hunk' })
        map('n', '<leader>hb', function()
          gs.blame_line { full = false }
        end, { desc = 'git blame line' })
        map('n', '<leader>hd', gs.diffthis, { desc = 'git diff against index' })
        map('n', '<leader>hD', function()
          gs.diffthis '~'
        end, { desc = 'git diff against last commit' })

        -- Toggles
        map('n', '<leader>tb', gs.toggle_current_line_blame, { desc = 'toggle git blame line' })
        map('n', '<leader>td', gs.toggle_deleted, { desc = 'toggle git show deleted' })

        -- Text object
        map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', { desc = 'select git hunk' })
      end,
    },
  },

  {
    'catppuccin/nvim',
    name = 'catppuccin',
    priority = 1000,
    opts = { transparent_background = true },
  },

  {
    -- Set lualine as statusline
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    -- See `:help lualine.txt`
    opts = {
      options = {
        component_separators = '|',
        section_separators = '',
      },
      sections = {
        lualine_c = { { 'filename', path = 1 } },
        lualine_x = { 'swenv', 'filetype' },
      },
    },
  },

  {
    -- Shows open buffers at the top
    'akinsho/bufferline.nvim',
    version = '*',
    dependencies = 'nvim-tree/nvim-web-devicons',
    opts = {
      options = {
        diagnostics = 'nvim_lsp',
      },
      highlights = {
        fill = {
          bg = 'none',
        },
        background = {
          bg = 'none',
        },
        tab = {
          bg = 'none',
        },
        tab_selected = {
          bg = 'none',
        },
        tab_separator = {
          bg = 'none',
        },
        tab_separator_selected = {
          bg = 'none',
        },
        tab_close = {
          bg = 'none',
        },
        close_button = {
          bg = 'none',
        },
        close_button_visible = {
          bg = 'none',
        },
        close_button_selected = {
          bg = 'none',
        },
        buffer_visible = {
          bg = 'none',
        },
        buffer_selected = {
          bg = 'none',
          bold = true,
          italic = true,
        },
        numbers = {
          bg = 'none',
        },
        numbers_visible = {
          bg = 'none',
        },
        numbers_selected = {
          bg = 'none',
          bold = true,
        },
        diagnostic = {
          bg = 'none',
        },
        diagnostic_visible = {
          bg = 'none',
        },
        diagnostic_selected = {
          bg = 'none',
        },
        hint = {
          bg = 'none',
        },
        hint_visible = {
          bg = 'none',
        },
        hint_selected = {
          bg = 'none',
        },
        hint_diagnostic = {
          bg = 'none',
        },
        hint_diagnostic_visible = {
          bg = 'none',
        },
        hint_diagnostic_selected = {
          bg = 'none',
        },
        info = {
          bg = 'none',
        },
        info_visible = {
          bg = 'none',
        },
        info_selected = {
          bg = 'none',
        },
        info_diagnostic = {
          bg = 'none',
        },
        info_diagnostic_visible = {
          bg = 'none',
        },
        info_diagnostic_selected = {
          bg = 'none',
        },
        warning = {
          bg = 'none',
        },
        warning_visible = {
          bg = 'none',
        },
        warning_selected = {
          bg = 'none',
        },
        warning_diagnostic = {
          bg = 'none',
        },
        warning_diagnostic_visible = {
          bg = 'none',
        },
        warning_diagnostic_selected = {
          bg = 'none',
        },
        error = {
          bg = 'none',
        },
        error_visible = {
          bg = 'none',
        },
        error_selected = {
          bg = 'none',
        },
        error_diagnostic = {
          bg = 'none',
        },
        error_diagnostic_visible = {
          bg = 'none',
        },
        error_diagnostic_selected = {
          bg = 'none',
        },
        modified = {
          bg = 'none',
        },
        modified_visible = {
          bg = 'none',
        },
        modified_selected = {
          bg = 'none',
        },
        duplicate_selected = {
          bg = 'none',
        },
        duplicate_visible = {
          bg = 'none',
        },
        duplicate = {
          bg = 'none',
        },
        separator_selected = {
          bg = 'none',
        },
        separator_visible = {
          bg = 'none',
        },
        separator = {
          bg = 'none',
        },
        indicator_visible = {
          bg = 'none',
        },
        indicator_selected = {
          bg = 'none',
        },
        pick_selected = {
          bg = 'none',
        },
        pick_visible = {
          bg = 'none',
        },
        pick = {
          bg = 'none',
        },
        offset_separator = {
          bg = 'none',
        },
        trunc_marker = {
          bg = 'none',
        }
      }
    },
  },

  {
    -- Add indentation guides even on blank lines
    'lukas-reineke/indent-blankline.nvim',
    -- Enable `lukas-reineke/indent-blankline.nvim`
    -- See `:help ibl`
    main = 'ibl',
    opts = {},
  },

  -- 'gc' to comment visual regions/lines
  { 'numToStr/Comment.nvim',  opts = {} },

  -- Fuzzy Finder (files, lsp, etc)
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      -- Fuzzy Finder Algorithm which requires local dependencies to be built.
      -- Only load if `make` is available. Make sure you have the system
      -- requirements installed.
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        -- NOTE: If you are having trouble with this installation,
        --       refer to the README for telescope-fzf-native for more instructions.
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
      "nvim-telescope/telescope-live-grep-args.nvim",
      "nvim-telescope/telescope-ui-select.nvim",
      "debugloop/telescope-undo.nvim",
    },
    opts = function()
      local lga_actions = require("telescope-live-grep-args.actions")
      local telescope_actions = require("telescope.actions")

      return {
        defaults = {
          mappings = {
            i = {
              ['<C-u>'] = false,
              ['<C-d>'] = false,
              ["<C-Down>"] = telescope_actions.cycle_history_next,
              ["<C-Up>"] = telescope_actions.cycle_history_prev,
            },
          },
          path_display = { "truncate" },
        },
        extensions = {
          live_grep_args = {
            mappings = {
              i = {
                ["<C-k>"] = lga_actions.quote_prompt(),
                ["<C-i>"] = lga_actions.quote_prompt({ postfix = " --iglob " }),
              },
            },
          },
          undo = {
            side_by_side = true,
          },
        },
      }
    end,
  },

  -- File browser
  {
    'nvim-tree/nvim-tree.lua',
    opts = {
      view = {
        width = function()
          return math.floor(vim.opt.columns:get() * 0.5)
        end,
        float = {
          enable = true,
          open_win_config = function()
            local screen_w = vim.opt.columns:get()
            local screen_h = vim.opt.lines:get() - vim.opt.cmdheight:get()
            local window_w = screen_w * 0.8
            local window_h = screen_h * 0.8
            local window_w_int = math.floor(window_w)
            local window_h_int = math.floor(window_h)
            local center_x = (screen_w - window_w) / 2
            local center_y = ((vim.opt.lines:get() - window_h) / 2)
                - vim.opt.cmdheight:get()
            return {
              border = "rounded",
              relative = "editor",
              row = center_y,
              col = center_x,
              width = window_w_int,
              height = window_h_int,
            }
          end,
        },
      },
      filters = {
        git_ignored = false,
      },
    },
    dependencies = {
      'nvim-tree/nvim-web-devicons'
    }
  },

  {
    -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
      'nvim-treesitter/nvim-treesitter-context',
    },
    build = ':TSUpdate',
  },

  -- NOTE: Next Step on Your Neovim Journey: Add/Configure additional "plugins"
  -- for kickstart
  --       These are some example plugins that I've included in the kickstart repository.
  --       Uncomment any of the lines below to enable them.
  -- require 'kickstart.plugins.autoformat',
  -- require 'kickstart.plugins.debug',

  -- Auto close brackets and other pairs
  { 'm4xshen/autoclose.nvim', opts = {} },

  -- Use null-ls for linters, formatters etc. that don't support LSP
  {
    'jose-elias-alvarez/null-ls.nvim',
    opts = function()
      local null_ls = require('null-ls')
      local formatting = null_ls.builtins.formatting

      return {
        sources = {
          formatting.mdformat,
          formatting.shfmt.with({ extra_args = { '-i', '4' } }),
          formatting.prettier,
          formatting.black,
        },
      }
    end,
  },

  -- Surround selected text with brackets, quotes etc.
  {
    'kylechui/nvim-surround',
    version = '*', -- Use for stability; omit to use `main` branch for the latest features
    event = 'VeryLazy',
    opts = {},
  },

  -- Markdown preview
  {
    'iamcco/markdown-preview.nvim',
    cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
    ft = { 'markdown' },
    build = function() vim.fn['mkdp#util#install']() end,
  },

  {
    "chrishrb/gx.nvim",
    keys = { { "gx", "<cmd>Browse<cr>", mode = { "n", "x" } } },
    cmd = { "Browse" },
    init = function()
      vim.g.netrw_nogx = 1 -- disable netrw gx
    end,
    dependencies = { "nvim-lua/plenary.nvim" },
    config = true,      -- default settings
    submodules = false, -- not needed, submodules are required only for tests
  },

  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    }
  },

  { "lukas-reineke/virt-column.nvim", opts = {} },

  "AckslD/swenv.nvim",

  {
    "NoahTheDuke/vim-just",
    ft = { "just" },
  },

  -- NOTE: The import below can automatically add your own plugins,
  -- configuration, etc from `lua/custom/plugins/*.lua`
  --    You can use this folder to prevent any conflicts with this init.lua if
  --    you're interested in keeping up-to-date with whatever is in the
  --    kickstart repo.
  --    Uncomment the following line and add your plugins to
  --    `lua/custom/plugins/*.lua` to get going.
  --
  --    For additional information see:
  --    https://github.com/folke/lazy.nvim#-structuring-your-plugins
  -- { import = 'custom.plugins' },
}, {})

-- [[ Setting options ]]
-- See `:help vim.o`
-- NOTE: You can change these options as you wish!

-- Set highlight on search
vim.o.hlsearch = false

-- Set highlight on incsearch
vim.o.incsearch = true

-- Make line numbers default
vim.wo.number = true

-- Make line numbers relative
vim.o.relativenumber = true

vim.o.colorcolumn = '80'

-- Enable mouse mode
vim.o.mouse = 'a'

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.o.clipboard = 'unnamedplus'

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.wo.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = true

-- Min distance of cursor from screen top/bottom
vim.o.scrolloff = 4

-- Fix indentations
vim.o.expandtab = true
vim.o.smartindent = true
vim.o.tabstop = 2
vim.o.shiftwidth = 2

-- [[ Basic Keymaps ]]

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Center the cursor when navigating pages
vim.keymap.set('n', '<C-d>', '<C-d>zz', { desc = 'Navigate down half a page' })
vim.keymap.set('n', '<C-u>', '<C-u>zz', { desc = 'Navigate up half a page' })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

-- Format file
vim.keymap.set('n', '<leader>ff', vim.lsp.buf.format, { desc = '[F]ormat [F]ile' })

-- Save file
vim.keymap.set('n', '<C-S>', ':w<CR>', { desc = '[S]ave buffer' })

-- Navigate buffers
vim.keymap.set('n', ']b', ':bn<CR>', { desc = 'Next buffer' })
vim.keymap.set('n', '<leader>bn', ':bn<CR>', { desc = '[N]ext buffer' })
vim.keymap.set('n', '[b', ':bp<CR>', { desc = 'Previous buffer' })
vim.keymap.set('n', '<leader>bp', ':bp<CR>', { desc = '[P]revious buffer' })
vim.keymap.set('n', '<leader>bd', ':bp|bd #<CR>', { desc = '[D]elete buffer' })

-- Git log and status (using vim-flog)
vim.keymap.set('n', '<C-L>', ':Flog<CR>', { desc = 'Open Git [L]og' })
vim.keymap.set('n', '<C-G>', ':G<CR>', { desc = 'Open [G]it status' })

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

-- [[ Configure color scheme ]]
vim.cmd.colorscheme 'catppuccin'

-- [[ Configure Telescope ]]
-- See `:help telescope` and `:help telescope.setup()`

-- Enable telescope fzf native, if installed
pcall(require('telescope').load_extension, 'fzf')

-- Enable telescope file browser, if installed
pcall(require('telescope').load_extension, 'file_browser')

-- Enable telescope live grep args, if installed
pcall(require('telescope').load_extension, 'live_grep_args')

-- Enable telescope ui select, if installed
pcall(require('telescope').load_extension, 'ui-select')

-- Enable telescope undo, if installed
pcall(require('telescope').load_extension, 'undo')

-- Telescope live_grep in git root
-- Function to find the git root directory based on the current buffer's path
local function find_git_root()
  -- Use the current buffer's path as the starting point for the git search
  local current_file = vim.api.nvim_buf_get_name(0)
  local current_dir
  local cwd = vim.fn.getcwd()
  -- If the buffer is not associated with a file, return nil
  if current_file == '' then
    current_dir = cwd
  else
    -- Extract the directory from the current file's path
    current_dir = vim.fn.fnamemodify(current_file, ':h')
  end

  -- Find the Git root directory from the current file's path
  local git_root = vim.fn.systemlist('git -C ' .. vim.fn.escape(current_dir, ' ') .. ' rev-parse --show-toplevel')[1]
  if vim.v.shell_error ~= 0 then
    print 'Not a git repository. Searching on current working directory'
    return cwd
  end
  return git_root
end

-- Custom live_grep function to search in git root
local function live_grep_git_root()
  local git_root = find_git_root()
  if git_root then
    require('telescope').extensions.live_grep_args.live_grep_args {
      search_dirs = { git_root },
    }
  end
end

vim.api.nvim_create_user_command('LiveGrepGitRoot', live_grep_git_root, {})

-- See `:help telescope.builtin`
vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
vim.keymap.set('n', '<leader><space>', require('telescope.builtin').buffers, { desc = '[ ] Find existing buffers' })
vim.keymap.set('n', '<leader>/', function()
  -- You can pass additional configuration to telescope to change theme, layout, etc.
  require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, { desc = '[/] Fuzzily search in current buffer' })

local function telescope_live_grep_open_files()
  require('telescope.builtin').live_grep {
    grep_open_files = true,
    prompt_title = 'Live Grep in Open Files',
  }
end
vim.keymap.set('n', '<leader>s/', telescope_live_grep_open_files, { desc = '[S]earch [/] in Open Files' })
vim.keymap.set('n', '<leader>ss', require('telescope.builtin').builtin, { desc = '[S]earch [S]elect Telescope' })
vim.keymap.set('n', '<leader>gf', require('telescope.builtin').git_files, { desc = 'Search [G]it [F]iles' })
vim.keymap.set('n', '<leader>gh', ':G log %<CR>', { desc = '[G]it File [H]istory' })
vim.keymap.set('n', '<leader>gl', function()
    vim.cmd('G log -L' .. vim.fn.line('.') .. ',' .. vim.fn.line('.') .. ':' .. '%')
  end,
  { desc = '[G]it [L]ine History' })
vim.keymap.set('n', '<leader>sff', require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>sfh', function()
    require 'telescope.builtin'.find_files({ hidden = true })
  end,
  { desc = '[S]earch [F]iles [H]idden' })
vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', require('telescope').extensions.live_grep_args.live_grep_args,
  { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sG', ':LiveGrepGitRoot<cr>', { desc = '[S]earch by [G]rep on Git Root' })
vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>sr', require('telescope.builtin').resume, { desc = '[S]earch [R]esume' })
vim.keymap.set('n', '<leader>u', "<cmd>Telescope undo<cr>", { desc = 'Telescope [U]ndo' })
vim.keymap.set('n', '<leader>fb', ':NvimTreeFindFileToggle!<CR>', { desc = '[F]ile [B]rowser' })

-- [[ Configure Treesitter ]]
-- See `:help nvim-treesitter`
-- Defer Treesitter setup after first render to improve startup time of 'nvim {filename}'
vim.defer_fn(function()
  require('nvim-treesitter.configs').setup {
    -- Add languages to be installed here that you want installed for treesitter
    ensure_installed = { 'c', 'cpp', 'go', 'lua', 'python', 'rust', 'tsx', 'javascript', 'typescript', 'vimdoc', 'vim', 'bash', 'graphql', 'markdown' },

    -- Autoinstall languages that are not installed. Defaults to false (but you can change for yourself!)
    auto_install = true,

    highlight = { enable = true },
    indent = { enable = true },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = '<c-space>',
        node_incremental = '<c-space>',
        scope_incremental = '<c-s>',
        node_decremental = '<M-space>',
      },
    },
    textobjects = {
      select = {
        enable = true,
        lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
        keymaps = {
          -- You can use the capture groups defined in textobjects.scm
          ['aa'] = '@parameter.outer',
          ['ia'] = '@parameter.inner',
          ['af'] = '@function.outer',
          ['if'] = '@function.inner',
          ['ac'] = '@class.outer',
          ['ic'] = '@class.inner',
        },
      },
      move = {
        enable = true,
        set_jumps = true, -- whether to set jumps in the jumplist
        goto_next_start = {
          [']m'] = '@function.outer',
          [']]'] = '@class.outer',
        },
        goto_next_end = {
          [']M'] = '@function.outer',
          [']['] = '@class.outer',
        },
        goto_previous_start = {
          ['[m'] = '@function.outer',
          ['[['] = '@class.outer',
        },
        goto_previous_end = {
          ['[M'] = '@function.outer',
          ['[]'] = '@class.outer',
        },
      },
      swap = {
        enable = true,
        swap_next = {
          ['<leader>a'] = '@parameter.inner',
        },
        swap_previous = {
          ['<leader>A'] = '@parameter.inner',
        },
      },
    },
  }

  -- MDX
  vim.filetype.add({
    extension = {
      mdx = "mdx",
    },
  })
  vim.treesitter.language.register("markdown", "mdx")
end, 0)

-- [[ Configure LSP ]]
--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(_, bufnr)
  -- NOTE: Remember that lua is a real programming language, and as such it is possible
  -- to define small helper and utility functions so you don't have to repeat yourself
  -- many times.
  -- In this case, we create a function that lets us more easily define mappings specific
  -- for LSP related items. It sets the mode, buffer and description for us each time.
  local nmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end

    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end

  nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
  nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

  nmap('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
  nmap('gr', function()
    require('telescope.builtin').lsp_references({ show_line = false })
  end, '[G]oto [R]eferences')
  nmap('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
  nmap('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
  nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
  nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

  -- See `:help K` for why this keymap
  nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
  nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

  -- Lesser used LSP functionality
  nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
  nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
  nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
  nmap('<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, '[W]orkspace [L]ist Folders')

  -- Create a command `:Format` local to the LSP buffer
  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    vim.lsp.buf.format()
  end, { desc = 'Format current buffer with LSP' })
end

-- document existing key chains
require('which-key').add {
  { "<leader>b",  group = "[B]uffer" },
  { "<leader>b_", hidden = true },
  { "<leader>c",  group = "[C]ode" },
  { "<leader>c_", hidden = true },
  { "<leader>d",  group = "[D]ocument" },
  { "<leader>d_", hidden = true },
  { "<leader>f",  group = "[F]iles" },
  { "<leader>f_", hidden = true },
  { "<leader>g",  group = "[G]it" },
  { "<leader>g_", hidden = true },
  { "<leader>h",  group = "Git [H]unk" },
  { "<leader>h_", hidden = true },
  { "<leader>r",  group = "[R]ename" },
  { "<leader>r_", hidden = true },
  { "<leader>s",  group = "[S]earch" },
  { "<leader>s_", hidden = true },
  { "<leader>t",  group = "[T]oggle" },
  { "<leader>t_", hidden = true },
  { "<leader>w",  group = "[W]orkspace" },
  { "<leader>w_", hidden = true },
}

-- register which-key VISUAL mode
-- required for visual <leader>hs (hunk stage) to work
require('which-key').add {
  { "<leader>",  group = "VISUAL <leader>", mode = "v" },
  { "<leader>h", desc = "Git [H]unk",       mode = "v" },
}

-- mason-lspconfig requires that these setup functions are called in this order
-- before setting up the servers.
require('mason').setup()
require('mason-lspconfig').setup()

-- Enable the following language servers
--  Feel free to add/remove any LSPs that you want here. They will
--  automatically be installed.
--
--  Add any additional override configuration in the following tables. They
--  will be passed to the `settings` field of the server config. You must look
--  up that documentation yourself.
--
--  If you want to override the default filetypes that your language server
--  will attach to you can define the property 'filetypes' to the map in question.
local servers = {
  -- clangd = {},
  gopls = {
    filetypes = { "go", "gomod", "gowork", "gotmpl" },
    cmd = { "gopls" },
  },
  pyright = {},
  ruff = {},
  rust_analyzer = {},
  -- tsserver = {}, -- Using typescript-tools.nvim instead
  html = { filetypes = { 'html', 'twig', 'hbs', 'template' } },
  htmx = {},
  astro = {},
  tailwindcss = {
    tailwindCSS = {
      experimental = {
        classRegex = {
          { "[\"'`](.*?)[\"'`]" }, -- for tailwind-variants
          { "cva\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]" },
          { "cx\\(([^)]*)\\)",  "(?:'|\"|`)([^']*)(?:'|\"|`)" }
        },
      },
    },
  },
  mdx_analyzer = { filetypes = { 'mdx' } },
  cssls = {
    css = {
      validate = true,
      lint = {
        unknownAtRules = "ignore"
      }
    },
    scss = {
      validate = true,
      lint = {
        unknownAtRules = "ignore"
      }
    },
    less = {
      validate = true,
      lint = {
        unknownAtRules = "ignore"
      }
    },
  },
  ['eslint@4.8.0'] = {},
  lua_ls = {
    Lua = {
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
      diagnostics = { globals = { "vim" } },
      -- NOTE: toggle below to ignore Lua_LS's noisy `missing-fields` warnings
      -- diagnostics = { disable = { 'missing-fields' } },
    },
  },
  asm_lsp = {},
  clangd = {},
}

-- Setup neovim lua configuration
require('neodev').setup()

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- Ensure the servers above are installed
local mason_lspconfig = require 'mason-lspconfig'

mason_lspconfig.setup {
  ensure_installed = vim.tbl_keys(servers),
  automatic_installation = true,
}

mason_lspconfig.setup_handlers {
  function(server_name)
    require('lspconfig')[server_name].setup {
      capabilities = capabilities,
      on_attach = on_attach,
      settings = servers[server_name],
      filetypes = (servers[server_name] or {}).filetypes,
    }
  end,
}

-- [[ Configure nvim-cmp ]]
-- See `:help cmp`
local cmp = require 'cmp'
local luasnip = require 'luasnip'
require('luasnip.loaders.from_vscode').lazy_load()
luasnip.config.setup {}

cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  completion = {
    completeopt = 'menu,menuone,noinsert',
  },
  mapping = cmp.mapping.preset.insert {
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete {},
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_locally_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.locally_jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  },
}

-- [[ Configure todo-comments.nvim ]]
vim.keymap.set("n", "]t", function()
  require("todo-comments").jump_next()
end, { desc = "Next todo comment" })

vim.keymap.set("n", "[t", function()
  require("todo-comments").jump_prev()
end, { desc = "Previous todo comment" })

vim.keymap.set("n", "<leader>tq", ":TodoQuickFix<CR>", { desc = "[T]odo [Q]uickfix" })
vim.keymap.set("n", "<leader>tt", ":TodoTelescope<CR>", { desc = "[T]odo [T]elescope" })

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et

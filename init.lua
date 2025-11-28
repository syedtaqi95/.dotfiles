--[[
Neovim config based on kickstart.nvim with my mods :)
-]]

-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

-- Disable netrw as using alternative file explorer
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- [[ Setting options ]]
-- See `:help vim.o`

vim.o.winborder = "rounded"

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

-- Don't show the mode, since it's already in the status line
vim.o.showmode = false

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.schedule(function()
  vim.o.clipboard = 'unnamedplus'
end)

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

-- Decrease mapped sequence wait time
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
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics [Q]uickfix list' })
vim.keymap.set({ 'n' }, '[d', function()
  vim.diagnostic.jump({ count = -1, float = true })
end, { desc = 'Jump to previous diagnostic message' })
vim.keymap.set({ 'n' }, ']d', function()
  vim.diagnostic.jump({ count = 1, float = true })
end, { desc = 'Jump to next diagnostic message' })


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

--  [[ LSP Configuration ]]
--  Enable the following language servers
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
  -- ts_ls = {}, -- Using typescript-tools.nvim
  taplo = {},
  html = {
    filetypes = { 'html', 'twig', 'hbs', 'template' }
  },
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
  mdx_analyzer = {
    filetypes = { 'mdx' }
  },
  cssls = {
    settings = {
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
      }
    },
  },
  lua_ls = {
    filetypes = { "lua" },
    settings = {
      Lua = {
        workspace = { checkThirdParty = false },
        telemetry = { enable = false },
        -- Toggle below to ignore Lua_LS's noisy `missing-fields` warnings
        diagnostics = { disable = { 'missing-fields' } },
      },
    }
  },
  asm_lsp = {},
  clangd = {},
}

-- Diagnostic Config
-- See :help vim.diagnostic.Opts
vim.diagnostic.config {
  severity_sort = true,
  float = { border = 'rounded', source = 'if_many' },
  underline = { severity = vim.diagnostic.severity.ERROR },
  signs = vim.g.have_nerd_font and {
    text = {
      [vim.diagnostic.severity.ERROR] = '󰅚 ',
      [vim.diagnostic.severity.WARN] = '󰀪 ',
      [vim.diagnostic.severity.INFO] = '󰋽 ',
      [vim.diagnostic.severity.HINT] = '󰌶 ',
    },
  } or {},
  virtual_text = {
    source = 'if_many',
    spacing = 2,
    format = function(diagnostic)
      local diagnostic_message = {
        [vim.diagnostic.severity.ERROR] = diagnostic.message,
        [vim.diagnostic.severity.WARN] = diagnostic.message,
        [vim.diagnostic.severity.INFO] = diagnostic.message,
        [vim.diagnostic.severity.HINT] = diagnostic.message,
      }
      return diagnostic_message[diagnostic.severity]
    end,
  },
}

-- [[ Basic Autocommands ]]

-- Highglight on yank
-- See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = vim.api.nvim_create_augroup('YankHighlight', { clear = true }),
  pattern = '*',
  desc = "Highlight when yanking text",
})

-- [[ Install `lazy.nvim` plugin manager ]]
--    https://github.com/folke/lazy.nvim
--    `:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out,                            "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
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
  'NMAC427/guess-indent.nvim', -- Detect tabstop and shiftwidth automatically

  {
    -- Add indentation guides even on blank lines
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    opts = {},
  },

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

  -- Use non-LSP formatters like prettier in neovim
  {
    "stevearc/conform.nvim",
    ---@module "conform"
    ---@type conform.setupOpts
    opts = {
      formatters_by_ft = {
        javascript = { "prettier" },
        typescript = { "prettier" },
        javascriptreact = { "prettier" },
        typescriptreact = { "prettier" },
        html = { "prettier" },
        css = { "prettier" },
        json = { "prettier" },
        yaml = { "prettier" },
        markdown = { "prettier" },
        mdx = { "prettier" },
        graphql = { "prettier" },
      },
      default_format_opts = {
        lsp_format = "fallback",
      },
    },
    keys = {
      {
        "<leader>ff",
        function()
          require("conform").format({ async = true })
        end,
        desc = "[F]ormat [F]ile"
      }
    }
  },

  -- [[ LSP Plugins ]]
  {
    -- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
    -- used for completion, annotations and signatures of Neovim apis
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        -- Load luvit types when the `vim.uv` word is found
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
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

  -- Main LSP Configuration
  {
    'neovim/nvim-lspconfig',

    dependencies = {
      { 'mason-org/mason.nvim',           opts = {} },
      { 'mason-org/mason-lspconfig.nvim', opts = { ensure_installed = vim.tbl_keys(servers) } },
      { 'j-hui/fidget.nvim',              opts = {} },
      'saghen/blink.cmp',
    },

    config = function()
      local capabilities = require('blink.cmp').get_lsp_capabilities()

      for name, cfg in pairs(servers) do
        cfg.capabilities = vim.tbl_deep_extend('force', capabilities, cfg.capabilities or {})
        vim.lsp.config[name] = cfg
      end

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
        callback = function(event)
          local bufnr = event.buf

          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = bufnr, desc = "LSP: " .. desc })
          end

          map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
          map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
          map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
          map('gr', function()
            require('telescope.builtin').lsp_references({ show_line = false })
          end, '[G]oto [R]eferences')
          map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
          map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
          map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
          map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

          -- See `:help K` for this keymap
          map('K', vim.lsp.buf.hover, 'Hover Documentation')
          map('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

          -- Lesser used LSP functionality
          map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
          map('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
          map('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
          map('<leader>wl', function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
          end, '[W]orkspace [L]ist Folders')
        end,
      })
    end,
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
      diff_opts = {
        internal = true,
        linematch = 1,
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
    config = function()
      vim.cmd.colorscheme 'catppuccin'
    end,
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
        pickers = {
          diagnostics = {
            layout_strategy = 'vertical',
            layout_config = {
              preview_cutoff = 0,
              preview_height = 0.4,
            },
          },
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
    },
    build = ':TSUpdate',
  },

  -- Show code context
  {
    'nvim-treesitter/nvim-treesitter-context',
    config = function()
      require("treesitter-context").setup {
        enable = true,
        max_lines = 8,
      }
    end
  },

  -- NOTE: Next Step on Your Neovim Journey: Add/Configure additional "plugins"
  -- for kickstart
  --       These are some example plugins that I've included in the kickstart repository.
  --       Uncomment any of the lines below to enable them.
  -- require 'kickstart.plugins.autoformat',
  -- require 'kickstart.plugins.debug',

  -- Auto close brackets and other pairs
  { 'm4xshen/autoclose.nvim', opts = {} },

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

  -- Select python virtual environment from inside neovim
  {
    'linux-cultist/venv-selector.nvim',
    dependencies = { 'neovim/nvim-lspconfig', 'nvim-telescope/telescope.nvim', 'mfussenegger/nvim-dap-python' },
    opts = {
      -- Your options go here
      -- name = "venv",
      -- auto_refresh = false
    },
    event = 'VeryLazy', -- Optional: needed only if you want to type `:VenvSelect` without a keymapping
    keys = {
      -- Keymap to open VenvSelector to pick a venv.
      { '<leader>vs', '<cmd>VenvSelect<cr>' },
      -- Keymap to retrieve the venv from a cache (the one previously used for the same project directory).
      { '<leader>vc', '<cmd>VenvSelectCached<cr>' },
    },
  },

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
}, {
  ui = {
    -- If you are using a Nerd Font: set icons to an empty table which will use the
    -- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
})

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
    require 'telescope.builtin'.find_files({ hidden = true, no_ignore = true })
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

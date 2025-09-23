-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Set leader key early
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Set environment path
if vim.env.VIM_PATH ~= "" and vim.env.VIM_PATH ~= nil then
  vim.env.PATH = vim.env.VIM_PATH
end

-- Basic Vim settings
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.list = true
vim.opt.swapfile = false
vim.opt.termguicolors = true
vim.opt.colorcolumn = "100"
vim.opt.hidden = true
vim.opt.autowrite = true
vim.opt.timeoutlen = 500
vim.opt.ttimeoutlen = 10

-- Configure ripgrep for grep
if vim.fn.executable('rg') == 1 then
  vim.opt.grepprg = 'rg --color=never'
end

-- GO-specific settings
vim.g.go_build_tags = 'cff'
vim.g.go_list_type = "quickfix"

-- Set up lazy.nvim
require("lazy").setup({
  -- Colorscheme
  {
    "sainnhe/everforest",
    lazy = false,
    priority = 1000,
    config = function()
      vim.g.everforest_better_performance = 1
      vim.g.everforest_background = 'hard'
      vim.cmd.colorscheme("everforest")
    end,
  },

  -- File manager - oil.nvim
  {
    "stevearc/oil.nvim",
    lazy = false,
    keys = {
      { "-", "<cmd>Oil<cr>", desc = "Open parent directory" },
    },
    config = function()
      require("oil").setup({
        default_file_explorer = true,
        delete_to_trash = true,
        skip_confirm_for_simple_edits = true,
        view_options = {
          show_hidden = false,
          natural_order = true,
        },
        keymaps = {
          ["<C-h>"] = false,
          ["<C-l>"] = false,
        },
      })
    end,
  },

  -- Telescope - fuzzy finder
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    keys = {
      { "<leader>p", "<cmd>Telescope find_files<cr>", desc = "Find files" },
      { "<leader>b", "<cmd>Telescope buffers<cr>", desc = "Find buffers" },
      { "<leader>m", "<cmd>Telescope oldfiles<cr>", desc = "Recent files" },
      { "<leader>g", function()
        require("telescope.builtin").grep_string({ search = vim.fn.expand("<cword>") })
      end, desc = "Grep word under cursor" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
      { "<leader>fs", "<cmd>Telescope grep_string<cr>", desc = "Grep string" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help tags" },
      { "<leader>fk", "<cmd>Telescope keymaps<cr>", desc = "Keymaps" },
      { "<leader>fc", "<cmd>Telescope commands<cr>", desc = "Commands" },
      { "<leader>fr", "<cmd>Telescope resume<cr>", desc = "Resume last search" },
      { "<leader>fgs", "<cmd>Telescope git_status<cr>", desc = "Git status" },
      { "<leader>fgc", "<cmd>Telescope git_commits<cr>", desc = "Git commits" },
      { "<leader>fgb", "<cmd>Telescope git_branches<cr>", desc = "Git branches" },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
      },
    },
    config = function()
      local telescope = require("telescope")
      local actions = require("telescope.actions")
      
      telescope.setup({
        defaults = {
          file_ignore_patterns = { "node_modules", ".git/" },
          layout_strategy = "vertical",
          layout_config = {
            width = .9,
            height = .9,
            bottom_pane = {
              height = 0.6,
              preview_cutoff = 120,
              prompt_position = "bottom",
            },
          },
          sorting_strategy = "descending",
          mappings = {
            i = {
              ["<C-n>"] = actions.move_selection_next,
              ["<C-p>"] = actions.move_selection_previous,
              ["<Down>"] = actions.move_selection_next,
              ["<Up>"] = actions.move_selection_previous,
            },
            n = {
              ["<C-n>"] = actions.move_selection_next,
              ["<C-p>"] = actions.move_selection_previous,
            },
          },
        },
        pickers = {
          find_files = {
            find_command = { "rg", "--files", "--hidden", "-g", "!.git" },
          },
        },
      })
      telescope.load_extension("fzf")
    end,
  },

  -- LSP Configuration
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "williamboman/mason.nvim",
    },
    config = function()
      local lspconfig = require('lspconfig')
      local opts = { noremap = true, silent = true }
      
      -- LSP capabilities
      local capabilities = require('cmp_nvim_lsp').default_capabilities()
      
      -- LSP attach function
      local on_attach = function(client, bufnr)
        vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
        
        local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
        
        buf_set_keymap('n', 'gf', '<cmd>lua vim.lsp.buf.format({async=true})<CR>', opts)
        buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
        buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
        buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
        buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
        buf_set_keymap('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
        buf_set_keymap('n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
        buf_set_keymap('n', '<space>f', '<cmd>lua vim.lsp.buf.format()<CR>', opts)
        
        -- Diagnostic keybindings
        buf_set_keymap('n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
        buf_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
        buf_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
        buf_set_keymap('n', '<space>dl', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)
      end

      -- Configure LSP servers
      lspconfig.gopls.setup({
        cmd = {'gopls', '-remote=auto'},
        on_attach = on_attach,
        capabilities = capabilities,
        flags = {
          debounce_text_changes = 300, -- Optimized from 1000ms
        },
        settings = {
          gopls = {
            staticcheck = true,
          },
        },
      })

      lspconfig.tailwindcss.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        filetypes = { 'html', 'templ' },
        flags = {
          debounce_text_changes = 300,
        },
      })

      lspconfig.templ.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        cmd = { "templ", "lsp", "-goplsLog=/var/log/templ-gopls.log", "-log=/var/log/templ.log" },
        filetypes = { 'templ' },
        flags = {
          debounce_text_changes = 300,
        },
      })

      lspconfig.eslint.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        filetypes = { "javascript", "typescript" },
        flags = {
          debounce_text_changes = 300,
        },
        settings = {
          eslint = {
            options = {
              configFile = vim.fn.expand("~/go-code/tools/eslint/eslint.config.ts")
            }
          }
        }
      })

      lspconfig.ts_ls.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        filetypes = { "javascript", "typescript" },
        flags = {
          debounce_text_changes = 300,
        },
      })

      -- Custom uLSP setup for Go
      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'go',
        callback = function(args)
          vim.lsp.start({
            cmd = { 'socat', '-', 'tcp:localhost:27883,ignoreeof' },
            flags = {
              debounce_text_changes = 300, -- Optimized from 1000ms
            },
            capabilities = capabilities,
            filetypes = { 'go' },
            root_dir = vim.fs.root(args.buf, { '.git' }),
            single_file_support = false,
            on_attach = function(client, bufnr)
              -- Suppress connection messages
              client.config.on_error = function() end
              on_attach(client, bufnr)
            end,
            handlers = {
              -- Suppress window/showMessage notifications
              ["window/showMessage"] = function() end,
              -- ["window/logMessage"] = function() end,
            },
            docs = {
              description = [[
                uLSP brought to you by the IDE team!
                By utilizing uLSP in Neovim, you acknowledge that this integration is provided 'as-is' with no warranty, express or implied.
                We make no guarantees regarding its functionality, performance, or suitability for any purpose, and absolutely no support will be provided.
                Use at your own risk, and may the code gods have mercy on your soul
              ]],
            },
          })
        end,
      })
    end,
  },

  -- Mason - LSP installer
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    config = function()
      require("mason").setup()
    end,
  },

  -- Completion
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local cmp = require('cmp')
      cmp.setup({
        sources = {
          { name = 'nvim_lsp' },
        },
        snippet = {
          expand = function(args)
            vim.snippet.expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({}),
      })
    end,
  },

  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require('nvim-treesitter.configs').setup({
        ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "go", "templ", "html", "typescript" },
        sync_install = false,
        auto_install = true,
        highlight = {
          enable = true,
          disable = function(lang, buf)
            local max_filesize = 100 * 1024 -- 100 KB
            local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
            if ok and stats and stats.size > max_filesize then
              return true
            end
          end,
          additional_vim_regex_highlighting = false,
        },
      })
    end,
  },

  -- DAP - Debug Adapter Protocol
  {
    "mfussenegger/nvim-dap",
    keys = {
      { "<Leader>dc", function() require('dap').continue() end, desc = "Continue" },
      { "<Leader>do", function() require('dap').step_over() end, desc = "Step Over" },
      { "<Leader>di", function() require('dap').step_into() end, desc = "Step Into" },
      { "<Leader>du", function() require('dap').step_out() end, desc = "Step Out" },
      { "<Leader>db", function() require('dap').toggle_breakpoint() end, desc = "Toggle Breakpoint" },
      { "<Leader>dr", function() require('dap').repl.open() end, desc = "Open REPL" },
      { "<Leader>dl", function() require('dap').run_last() end, desc = "Run Last" },
    },
    config = function()
      local dap = require('dap')
      
      dap.adapters.delve = function(callback, config)
        if config.mode == 'remote' and config.request == 'attach' then
          callback({
            type = 'server',
            host = config.host or '127.0.0.1',
            port = config.port or '2345'
          })
        else
          callback({
            type = 'server',
            port = '${port}',
            executable = {
              command = 'dlv',
              args = { 'dap', '-l', '127.0.0.1:${port}', '--log', '--log-output=dap' },
              detached = vim.fn.has("win32") == 0,
            }
          })
        end
      end
      
      dap.configurations.go = {
        {
          request = "attach",
          name = "Attach to Go Slate",
          mode = "remote",
          type = "go",
          debugAdapter = "dlv-dap",
          port = 2346,
          host = "127.0.0.1",
          trace = "info",
          substitutePath = {
            { from = "${env:GOPATH}/src", to = "src" },
            { from = "${env:GOPATH}/bazel-go-code/external/", to = "external/" },
            { from = "${env:GOPATH}/bazel-out/", to = "bazel-out/" },
            { from = "${env:GOPATH}/bazel-go-code/external/go_sdk", to = "GOROOT/" },
          },
        },
        {
          type = "delve",
          request = "attach",
          name = "Attach to Go",
          mode = "remote",
          substitutePath = {
            { from = "${env:GOPATH}/src", to = "src" },
            { from = "${env:GOPATH}/bazel-go-code/external/", to = "external/" },
            { from = "${env:GOPATH}/bazel-out/", to = "bazel-out/" },
            { from = "${env:GOPATH}/bazel-go-code/external/go_sdk", to = "GOROOT/" },
          },
        },
      }
    end,
  },

  -- Git integration
  {
    "tpope/vim-fugitive",
    cmd = { "Git", "Ggrep", "GBrowse" },
  },

  -- Text manipulation
  {
    "tpope/vim-surround",
    event = "VeryLazy",
  },
  {
    "tpope/vim-repeat",
    event = "VeryLazy",
  },
  {
    "tpope/vim-unimpaired",
    event = "VeryLazy",
  },

  -- Clipboard integration
  {
    "ojroques/vim-oscyank",
    event = "VeryLazy",
  },

  -- AI assistance
  {
    "github/copilot.vim",
    event = "InsertEnter",
  },
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    keys = {
      { "<leader>cc", "<cmd>CodeCompanionChat<cr>", desc = "Code Companion Chat" },
      { "<leader>ct", "<cmd>CodeCompanionToggle<cr>", desc = "Code Companion Toggle" },
      { "<leader>ca", "<cmd>CodeCompanionActions<cr>", desc = "Code Companion Actions" },
      { "<leader>ci", "<cmd>CodeCompanionInlineTransform<cr>", mode = "v", desc = "Inline Transform" },
    },
    config = function()
      require("codecompanion").setup({
        adapters = {
          http = {
            company_claude = {
              name = "company_claude",
              url = nil,
              env = { api_key = "dummy" },
              headers = {},
              request = function(self, messages, opts)
                local prompt = ""
                for _, message in ipairs(messages) do
                  if message.role == "user" then
                    prompt = message.content
                  end
                end

                local cmd = string.format('aifx agent run claude -c -p "%s"', prompt:gsub('"', '\\"'))
                local handle = io.popen(cmd)

                if not handle then
                  error("Failed to execute aifx command")
                end

                local result = handle:read("*a")
                local success = handle:close()

                if not success then
                  error("aifx command failed")
                end

                return {
                  choices = {
                    {
                      message = {
                        content = result:gsub("^%s*(.-)%s*$", "%1")
                      }
                    }
                  }
                }
              end
            }
          }
        },
        strategies = {
          chat = { adapter = "company_claude" },
          inline = { adapter = "company_claude" }
        }
      })
    end,
  },
})

-- Additional filetype setup
vim.filetype.add({ extension = { templ = "templ" } })

-- Key mappings
local opts = { noremap = true, silent = true }

-- Navigation
vim.keymap.set('n', '<C-k>', ':cp<Enter>zz', opts)
vim.keymap.set('n', '<C-j>', ':cn<Enter>zz', opts)
vim.keymap.set('n', '<C-d>', '<C-d>zz', opts)
vim.keymap.set('n', '<C-u>', '<C-u>zz', opts)
vim.keymap.set('n', 'n', 'nzz', opts)
vim.keymap.set('n', 'N', 'Nzz', opts)

-- Quickfix
vim.keymap.set('n', '<leader>q', ':cclose<Enter>', opts)

-- OSC Yank
vim.keymap.set('n', '<leader>c', '<Plug>OSCYankOperator', {})
vim.keymap.set('n', '<leader>cc', '<leader>c_', {})
vim.keymap.set('v', '<leader>c', '<Plug>OSCYankVisual', {})

-- DAP hover widgets
vim.keymap.set({'n', 'v'}, '<Leader>dh', function()
  require('dap.ui.widgets').hover()
end, opts)
vim.keymap.set({'n', 'v'}, '<Leader>dp', function()
  require('dap.ui.widgets').preview()
end, opts)
vim.keymap.set('n', '<Leader>df', function()
  local widgets = require('dap.ui.widgets')
  widgets.centered_float(widgets.frames)
end, opts)
vim.keymap.set('n', '<Leader>ds', function()
  local widgets = require('dap.ui.widgets')
  widgets.centered_float(widgets.scopes)
end, opts)

-- Custom commands
vim.api.nvim_create_user_command('Funcs', function()
  vim.cmd('Ggrep "func .*\\ ' .. vim.fn.expand('<cword>') .. '("')
end, {})

-- SourceGraph functions
function GetSourceGraphLinkLegacy(repo)
  local remote = vim.trim(vim.fn.system("git remote get-url origin"))
  remote = remote:gsub("gitolite@", "")
  remote = remote:gsub(":", "/")
  remote = remote:gsub("%.git$", "")
  local commit = vim.trim(vim.fn.system("git merge-base @ origin/" .. repo))
  local filename = vim.trim(vim.fn.system("git ls-files --full-name " .. vim.fn.expand("%")))
  local url = "https://sourcegraph.uberinternal.com/" .. remote .. "@" .. commit .. "/-/blob/" .. filename .. "#L" .. vim.fn.line(".") .. ":" .. vim.fn.col(".")
  return url
end

function CopySourceGraphLinkToClipboard()
  local url = GetSourceGraphLinkLegacy("master")
  local commit = vim.trim(vim.fn.system("git merge-base @ origin/master"))
  if vim.v.shell_error ~= 0 then
    url = GetSourceGraphLinkLegacy("main")
  end
  vim.fn.setreg("+", url)
  vim.cmd("OSCYankRegister +")
  print("Copied SourceGraph URL to clipboard: " .. url)
end

function CopySourceGraphLinkForPhab()
  local url = GetSourceGraphLink()
  vim.fn.setreg("+", "[[ " .. url .. " | " .. vim.fn.expand("%:t") .. ":" .. vim.fn.line(".") .. " ]]")
  print("Copied SourceGraph URL to clipboard with [[ ... | ... ]] wrapper")
end

vim.keymap.set('n', '<leader><C-g>', CopySourceGraphLinkToClipboard, { silent = true })
vim.keymap.set('n', '<leader><C-p>', CopySourceGraphLinkForPhab, { silent = true })

-- Go format and imports function
function GoFormatAndImports(wait_ms)
  if vim.lsp.buf.format == nil then
    vim.lsp.buf.formatting_sync(nil, wait_ms)
  else
    vim.lsp.buf.format({
      timeout_ms = wait_ms,
    })
  end
  local params = vim.lsp.util.make_range_params()
  params.context = {only = {"source.organizeImports"}}
  local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, wait_ms)
  for _, res in pairs(result or {}) do
    for _, r in pairs(res.result or {}) do
      if r.edit then
        vim.lsp.util.apply_workspace_edit(r.edit, "utf-8")
      else
        vim.lsp.buf.execute_command(r.command)
      end
    end
  end
end

-- Uncomment to enable format on save for Go files
-- vim.api.nvim_create_autocmd("BufWritePre", {
--   pattern = "*.go",
--   callback = function()
--     GoFormatAndImports(3000)
--   end,
-- })

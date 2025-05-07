if $VIM_PATH != ""
        let $PATH = $VIM_PATH
endif

call plug#begin()
packadd matchit

let mapleader = ' '

Plug 'ctrlpvim/ctrlp.vim'
Plug 'github/copilot.vim'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/nvim-cmp'
Plug 'mfussenegger/nvim-dap'
Plug 'neovim/nvim-lspconfig'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'ojroques/vim-oscyank'
Plug 'sainnhe/everforest'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-vinegar'
Plug 'williamboman/mason.nvim'

let g:everforest_better_performance = 1
let g:everforest_background = 'hard'
autocmd vimenter * ++nested colorscheme everforest
set shiftwidth=4 tabstop=4
if has('termguicolors')
  set termguicolors
endif
set number relativenumber
set list
set noswapfile
let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files']
let g:ctrlp_cmd = 'CtrlP .'

if executable('rg')
  set grepprg=rg\ --color=never
  let g:ctrlp_user_command = 'rg %s --files --color=never --glob ""'
endif


" Run lint and vet on save
 let g:go_metalinter_autosave = 1

let g:go_debug_windows = {
    \ 'vars':       'leftabove 70vnew',
    \ 'stack':      'leftabove 20new',
    \ 'out':        'botright 5new',
\ }

set colorcolumn=100
highlight ColorColumn ctermbg=0 guibg=lightgrey
:command Funcs Ggrep "func .*\ <cword>("

noremap <C-k> :cp<Enter>zz
noremap <C-j> :cn<Enter>zz
noremap <C-d> <C-d>zz
noremap <C-u> <C-u>zz
noremap - :Explore<Enter>
noremap <leader>q :cclose<Enter>
noremap <leader>g :Ggrep <cword> .<Enter>
noremap <leader>b :CtrlPBuffer<Enter>
noremap <leader>m :CtrlPMRUFiles<Enter>
noremap <leader>p :CtrlP .<Enter>
nmap <leader>c <Plug>OSCYankOperator
nmap <leader>cc <leader>c_
nmap n nzz
nmap N Nzz
vmap <leader>c <Plug>OSCYankVisual

" use quickfix instead of location list so the shortcuts above work
" universally
let g:go_list_type = "quickfix"
let g:ale_use_neovim_diagnostics_api = 1
set hidden
set autowrite " enables write on :make or :GoBuild

" GO-specific stuff
let g:go_build_tags = 'cff'

call plug#end()

function! GetSourceGraphLinkLegacy(repo)
  let l:remote = trim(system("git remote get-url origin"))
  let l:remote = substitute(l:remote, "gitolite@", "", "")
  let l:remote = substitute(l:remote, ":", "/", "")
  let l:remote = substitute(l:remote, "\.git$", "", "")
  let l:commit = trim(system(substitute("git merge-base @ origin/master", "master", a:repo, "")))
  let l:filename = trim(system("git ls-files --full-name " . expand("%")))
  let l:url = "https://sourcegraph.uberinternal.com/" . l:remote . "@" . l:commit . "/-/blob/" . l:filename . "#L" . line(".") . ":" . col(".")
  return l:url
endfunction

function! CopySourceGraphLinkToClipboard()
  let l:url = GetSourceGraphLinkLegacy("master")
  let l:commit = trim(system("git merge-base @ origin/master"))
  if v:shell_error
    let l:url = GetSourceGraphLinkLegacy("main")
  endif
  call setreg("+", l:url)
  OSCYankRegister +
  echo join(["Copied SourceGraph URL to clipboard:", l:url], " ")
endfunction

function! CopySourceGraphLinkForPhab()
  let l:url = GetSourceGraphLink()
  call setreg("+", "[[ " . l:url . " | " . expand("%:t") . ":" . line(".") . " ]]")
  echo "Copied SourceGraph URL to clipboard with [[ ... | ... ]] wrapper"
endfunction

noremap <silent> <leader><C-g> :call CopySourceGraphLinkToClipboard()<cr>
noremap <silent> <leader><C-p> :call CopySourceGraphLinkForPhab()<cr>

lua << EOF
-- require("CopilotChat").setup {
--  -- https://github.com/CopilotC-Nvim/CopilotChat.nvim?tab=readme-ov-file#configuration
-- }
vim.env.PATH = vim.env.VIM_PATH or vim.env.PATH
local opts = { noremap=true, silent=true }

local lspconfig_defaults = require('lspconfig').util.default_config
lspconfig_defaults.capabilities = vim.tbl_deep_extend(
  'force',
  lspconfig_defaults.capabilities,
  require('cmp_nvim_lsp').default_capabilities()
)
 
local lsp_capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())
local on_attach = function(client, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
 
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gf', '<cmd>lua vim.lsp.buf.format({async=true})<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
 
  -- You can delete this if you enable format-on-save.
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
end

-- Create an event handler for the FileType autocommand
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'go',
  callback = function(args)
    vim.lsp.start({
      cmd = { 'socat', '-', 'tcp:localhost:27883,ignoreeof' },
      flags = {
          debounce_text_changes = 1000,
      },
      capabilities = vim.lsp.protocol.make_client_capabilities(),
      filetypes = { 'go' },
      root_dir = vim.fs.root(args.buf, { '.git' }),
      single_file_support = false,
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

vim.filetype.add({ extension = { templ = "templ" } })
require("mason").setup()
require('lspconfig').gopls.setup {
        cmd = {'gopls', '-remote=auto'},
        on_attach = on_attach,
        flags = {
            -- Don't spam LSP with changes. Wait a second between each.
            debounce_text_changes = 1000,
        },
        init_options = {
            staticcheck = true,
        },
        capabilities = lsp_capabilities,
}
require('lspconfig').tailwindcss.setup {
	filetypes = { 'html', 'templ' },
}
require('lspconfig').templ.setup {
    on_attach = on_attach,
    capabilities = capabilities,
    cmd = { "templ", "lsp", "-goplsLog=/var/log/templ-gopls.log", "-log=/var/log/templ.log" },
    filetypes = { 'templ' },
}
require('lspconfig').eslint.setup {
    on_attach = on_attach,
    capabilities = capabilities,
    filetypes = { "javascript", "typescript" },
}
require('lspconfig').ts_ls.setup {
    on_attach = on_attach,
    capabilities = capabilities,
    filetypes = { "javascript", "typescript" },
}

local cmp = require('cmp')
cmp.setup({
  sources = {
    {name = 'nvim_lsp'},
  },
  snippet = {
    expand = function(args)
      -- You need Neovim v0.10 to use vim.snippet
      vim.snippet.expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({}),
})

require'nvim-treesitter.configs'.setup {
  -- A list of parser names, or "all" (the five listed parsers should always be installed)
  ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "go", "templ", "html", "typescript" },

  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = false,

  -- Automatically install missing parsers when entering buffer
  -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
  auto_install = true,

  -- List of parsers to ignore installing (or "all")
  ignore_install = { },

  ---- If you need to change the installation directory of the parsers (see -> Advanced Setup)
  -- parser_install_dir = "/some/path/to/store/parsers", -- Remember to run vim.opt.runtimepath:append("/some/path/to/store/parsers")!

  highlight = {
    enable = true,

    -- NOTE: these are the names of the parsers and not the filetype. (for example if you want to
    -- disable highlighting for the `tex` filetype, you need to include `latex` in this list as this is
    -- the name of the parser)
    -- list of language that will be disabled
    -- disable = { },
    -- Or use a function for more flexibility, e.g. to disable slow treesitter highlight for large files
    disable = function(lang, buf)
        local max_filesize = 100 * 1024 -- 100 KB
        local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
        if ok and stats and stats.size > max_filesize then
            return true
        end
    end,

    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
  },
}

local dap = require 'dap'
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
			{
				from = "${env:GOPATH}/src",
				to = "src",
			},
			{
				from = "${env:GOPATH}/bazel-go-code/external/",
				to = "external/",
			},
			{
				from = "${env:GOPATH}/bazel-out/",
				to = "bazel-out/",
			},
			{
				from = "${env:GOPATH}/bazel-go-code/external/go_sdk",
				to = "GOROOT/",
			},
		},
	},
	{
		type = "delve",
		request = "attach",
		name = "Attach to Go",
		mode = "remote",
		substitutePath = {
			{
				from = "${env:GOPATH}/src",
				to = "src",
			},
			{
				from = "${env:GOPATH}/bazel-go-code/external/",
				to = "external/",
			},
			{
				from = "${env:GOPATH}/bazel-out/",
				to = "bazel-out/",
			},
			{
				from = "${env:GOPATH}/bazel-go-code/external/go_sdk",
				to = "GOROOT/",
			},
		},
	},
}

vim.keymap.set('n', '<Leader>dc', function() require('dap').continue() end)
vim.keymap.set('n', '<Leader>do', function() require('dap').step_over() end)
vim.keymap.set('n', '<Leader>di', function() require('dap').step_into() end)
vim.keymap.set('n', '<Leader>du', function() require('dap').step_out() end)
vim.keymap.set('n', '<Leader>db', function() require('dap').toggle_breakpoint() end)
vim.keymap.set('n', '<Leader>dr', function() require('dap').repl.open() end)
vim.keymap.set('n', '<Leader>dl', function() require('dap').run_last() end)
vim.keymap.set({'n', 'v'}, '<Leader>dh', function()
  require('dap.ui.widgets').hover()
end)
vim.keymap.set({'n', 'v'}, '<Leader>dp', function()
  require('dap.ui.widgets').preview()
end)
vim.keymap.set('n', '<Leader>df', function()
  local widgets = require('dap.ui.widgets')
  widgets.centered_float(widgets.frames)
end)
vim.keymap.set('n', '<Leader>ds', function()
  local widgets = require('dap.ui.widgets')
  widgets.centered_float(widgets.scopes)
end)

function goFormatAndImports(wait_ms)
 
    -- Prefer `format` if available because `formatting_sync` has been deprecated as of nvim v0.8.0.
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
 
--vim.api.nvim_create_autocmd("BufWritePre", {
--    pattern = "*.go",
--    callback = function(args)
--        goFormatAndImports(3000)
--    end,
--})
EOF

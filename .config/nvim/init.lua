-- Boostrap Packer
local ensure_packer = function()
    local install_path = vim.fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
    if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
        vim.fn.system({ 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path })
        vim.cmd [[packadd packer.nvim]]
        return true
    end
    return false
end

local bootstrap = ensure_packer()

-- Package Manager
local packer = require 'packer'
packer.startup(function()
    local use = packer.use
    use 'wbthomason/packer.nvim'

    use 'echasnovski/mini.surround'
    use 'echasnovski/mini.trailspace'

    use 'mfussenegger/nvim-lint'
    use 'neovim/nvim-lspconfig'

    use { 'hrsh7th/nvim-cmp', requires = { { 'hrsh7th/cmp-buffer', 'hrsh7th/cmp-nvim-lsp', 'L3MON4D3/LuaSnip' } } }
    use { 'nvim-telescope/telescope.nvim', requires = { { 'nvim-lua/plenary.nvim' } } }
    use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }

    if bootstrap then packer.sync() end
end)

-- Behave like emacs
vim.opt.scrolljump = -50

-- Search
vim.opt.smartcase = true
vim.opt.ignorecase = true

vim.opt.clipboard = 'unnamedplus'
vim.opt.completeopt = 'menu,noinsert,noselect'
vim.opt.grepprg = "rg --vimgrep --no-heading -i $* /dev/null "
vim.opt.shortmess = 'aoOtT'
vim.opt.signcolumn = 'no'
vim.opt.switchbuf = 'useopen'

-- Statusline
vim.opt.statusline = " %F %h%m%r%=%-13.(%l,%c%V%) %P %<" -- just the default one
vim.opt.laststatus = 1                                   -- only if there are at least two windows

-- Identation
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.smartindent = true
vim.opt.softtabstop = 4
vim.opt.tabstop = 4

vim.opt.lazyredraw = true
vim.opt.relativenumber = true
vim.opt.wrap = false

-- Global diagnostics
vim.diagnostic.config { underline = true, virtual_text = { spacing = 2, prefix = "•" } }

-- Global keybinds
local map = function(mode, key, bind)
    vim.keymap.set(mode, key, bind, { noremap = true, silent = true })
end

vim.g.mapleader = " "
-- Normal Mode Keybinds
-- Go to next and previous error when LSP is not available
map('n', '<c-j>', ':cn<cr>')
map('n', '<c-k>', ':cp<cr>')
-- Go to next and previous buffer
map('n', '<c-h>', ':bn<cr>')
map('n', '<c-l>', ':bp<cr>')
-- map('n', '<leader>/', ':grep<space>')
map('n', '<leader><space>', ':b#<cr>')
map('n', '<leader>s', ':setlocal spell!<cr>')
map('n', 'Y', 'y$')
-- When we don't have LSP, just trim the whitespace
map('n', '<leader>f', require 'mini.trailspace'.trim)
-- * Mode Keybinds
-- When using '<', '>', or '=' keep the current text selected
map('x', '<', '<gv')
map('x', '=', '=gv')
map('x', '>', '>gv')
-- Terminal Mode Keybinds
map('t', '<esc><esc>', '<c-\\><c-n>')
-- Telescope Keybinds
map('n', '<leader>/', require 'telescope.builtin'.live_grep)
map('n', '<leader>b', require 'telescope.builtin'.buffers)
map('n', '<leader>e', require 'telescope.builtin'.find_files)
map('n', '<leader>?', function()
    require 'telescope.builtin'.oldfiles({ prompt_title = 'Recently Opened' })
end)

local on_attach = function(client, buff)
    -- Why is this on by default
    client.server_capabilities.semanticTokensProvider = nil
    local lsp_map = function(mode, key, bind)
        vim.keymap.set(mode, key, bind, { noremap = true, silent = true, buffer = buff })
    end
    -- Behave like the keybinds for tags
    lsp_map('n', '<c-]>', require 'telescope.builtin'.lsp_definitions)
    lsp_map('n', '<c-j>', vim.diagnostic.goto_next)
    lsp_map('n', '<c-k>', vim.diagnostic.goto_prev)
    lsp_map('n', '<leader>ca', vim.lsp.buf.code_action)
    lsp_map('n', '<leader>f', function() vim.lsp.buf.format { async = true } end)
    lsp_map('n', '<leader>r', require 'telescope.builtin'.lsp_references)
    lsp_map('n', '<space>R', vim.lsp.buf.rename)
end

local on_attach_rust = function(client, buff)
    local expand_macro = function()
        client.request(
            'rust-analyzer/expandMacro',
            vim.lsp.util.make_position_params(),
            function(_, macro)
                if macro == nil then
                    return vim.notify('no macro under the cursor', vim.log.levels.WARN)
                end

                local text = vim.split(macro.expansion, '\n', { plain = true })

                vim.lsp.util.open_floating_preview(text, 'rust', {
                    focus = true,
                    focus_id = "rust macro expansion",
                })
            end
        )
    end

    local view_ir = function(lvl)
        return function()
            client.request(
                'rust-analyzer/view' .. lvl,
                vim.lsp.util.make_position_params(0, nil),
                function(_, mir)
                    if mir == nil then
                        return vim.notify('fail to view ' .. lvl, vim.log.levels.WARN)
                    end

                    local text = vim.split(mir, '\n', { plain = true })

                    vim.lsp.util.open_floating_preview(text, 'rust', {
                        focus = true,
                        focus_id = "rust " .. lvl,
                    })
                end
            )
        end
    end

    vim.keymap.set('n', 'M', expand_macro, { noremap = true, silent = true, buffer = buff })
    vim.keymap.set('n', '<leader>vm', view_ir('Mir'), { noremap = true, silent = true, buffer = buff })
    vim.keymap.set('n', '<leader>vh', view_ir('Hir'), { noremap = true, silent = true, buffer = buff })

    on_attach(client, buff)
end

require 'mini.trailspace'.setup { only_in_normal_buffers = true }
require 'mini.surround'.setup {}

require 'telescope'.setup {
    defaults = { border = true, borderchars = { ' ' } }
}

require 'nvim-treesitter.configs'.setup {
    auto_install = true,
    highlight = { enable = true, additional_vim_regex_highlighting = false },
    incremental_selection = {
        enable = true,
        keymaps = {
            init_selection = false,
            scope_incremental = false,
            node_incremental = '.',
            node_decremental = ',',
        },
    },
}

require 'lint'.linters_by_ft = {
    sh = { 'shellcheck' }
}

require 'cmp'.setup {
    formatting = {
        format = function(_, vim_item)
            vim_item.abbr = string.sub(vim_item.abbr, 1, vim.opt.columns:get() * 0.9)
            return vim_item
        end
    },
    snippet = {
        expand = function(args)
            require 'luasnip'.lsp_expand(args.body)
        end
    },
    window = {
        documentation = false
    },
    mapping = require 'cmp'.mapping.preset.insert({
        ['<cr>'] = require 'cmp'.mapping.confirm({ select = true })
    }),
    sources = require 'cmp'.config.sources({
        { name = 'nvim_lsp' },
        { name = 'luasnip' }
    }, {
        -- This does not work for some reason
        { name = 'buffer' }
    })
}

local capabilities = require 'cmp_nvim_lsp'.default_capabilities(vim.lsp.protocol.make_client_capabilities())

require 'lspconfig'.clangd.setup {
    on_attach = on_attach,
    capabilities = capabilities,
    root_dir = require 'lspconfig'.util.root_pattern('build/compile_commands.json', '.git')
}

require 'lspconfig'.lua_ls.setup {
    on_attach = on_attach,
    capabilities = capabilities,
    -- Fix warning for global variable 'vim'
    settings = { Lua = { diagnostics = { globals = { 'vim' } } } }
}

require 'lspconfig'.zls.setup {
    settings = {
        zls = {
            semantic_tokens ='none',
        }
    }
}

require 'lspconfig'['rust_analyzer'].setup {
    on_attach = on_attach_rust,
    capabilities = capabilities,
    root_dir = require 'lspconfig'.util.root_pattern('Cargo.toml', 'rust-project.json', '.git'),
    settings = {
        ["rust-analyzer"] = {
            cargo = {
                features = "all"
            },
            procMacro = {
                enable = true
            },
            checkOnSave = {
                allFeatures = true,
                command = "clippy",
                extraArgs = {
                    "--",
                    "--no-deps",
                    "-Dclippy::correctness",
                    "-Dclippy::complexity",
                    "-Wclippy::perf",
                    "-Wclippy::pedantic",
                    "-Aclippy::module-name-repetitions",
                    "-Aclippy::struct-field-names",
                    "-Aclippy::missing-errors-doc",
                    "-Aclippy::used-underscore-binding",
                    "-Aclippy::missing_panics_doc"
                },
            },
        }
    }
}

require 'lspconfig'.hls.setup {
    on_attach = on_attach,
    capabilities = capabilities,
    filetypes = { 'haskell', 'lhaskell', 'cabal' }
}

require 'lspconfig'.tsserver.setup {
    on_attach = on_attach,
    capabilities = capabilities,
    filetypes = { "typescript", "typescriptreact", "typescript.tsx" },
    cmd = { "typescript-language-server", "--stdio" }
}

require 'lspconfig'.pyright.setup {}

local UsrFileype = vim.api.nvim_create_augroup("UsrFiletype", { clear = true })

vim.api.nvim_create_autocmd("Filetype", {
    callback = function()
        vim.opt_local.wrap = true
        vim.opt_local.linebreak = true
    end,
    group = UsrFileype,
    pattern = { "markdown", "text" }
})

vim.api.nvim_create_autocmd("Filetype", {
    callback = function()
        vim.opt_local.tabstop = 2
        vim.opt_local.softtabstop = 2
        vim.opt_local.shiftwidth = 2
    end,
    group = UsrFileype,
    pattern = "haskell,typescriptreact",
})

-- Disable line numbers in QuickFix lists
vim.api.nvim_create_autocmd("Filetype", {
    callback = function()
        vim.opt_local.number = false
        vim.opt_local.relativenumber = false
    end,
    pattern = "qf"
})

vim.api.nvim_create_autocmd("TermOpen", {
    callback = function()
        vim.opt_local.number = false
        vim.opt_local.relativenumber = false
    end
})

vim.api.nvim_create_autocmd("CmdlineEnter", {
    callback = function()
        vim.opt_local.hlsearch = true
    end,
    pattern = { "/", "?" }
})

vim.api.nvim_create_autocmd("CmdlineLeave", {
    callback = function()
        vim.opt_local.hlsearch = false
    end,
    pattern = { "/", "?" }
})

vim.api.nvim_create_autocmd("BufWritePost", {
    callback = function()
        require "lint".try_lint()
    end
})

-- TODO: Find a way to get rid of these
vim.cmd([[
au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
colorscheme based
]])

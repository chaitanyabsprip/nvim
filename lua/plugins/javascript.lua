---@type LazySpec[]
return {
    {
        'nvim-treesitter/nvim-treesitter',
        optional = true,
        opts = function(_, opts)
            require('config.lazy').extend_opts_list(
                opts,
                'ensure_installed',
                'javascript',
                'typescript',
                'jsdoc'
            )
        end,
    },
    {
        'williamboman/mason.nvim',
        optional = true,
        opts = function(_, opts)
            require('config.lazy').extend_opts_list(
                opts,
                'ensure_installed',
                'typescript-language-server',
                -- 'prettierd',
                'js-debug-adapter'
            )
        end,
    },
    {
        'nvimtools/none-ls.nvim',
        optional = true,
        ft = function(_, filetypes)
            return vim.list_extend(
                filetypes,
                { 'javascript', 'typescript', 'typescriptreact', 'javascriptreact' }
            )
        end,
        opts = function(_, opts)
            require('config.lazy').extend_opts_list(
                opts,
                'sources',
                ---@param builtins NullBuiltin
                function(builtins)
                    return {
                        builtins.formatting.prettier.with {
                            filetypes = {
                                'javascript',
                                'typescript',
                                'javascriptreact',
                                'typescriptreact',
                            },
                        },
                    }
                end
            )
        end,
    },
    {
        'pmizio/typescript-tools.nvim',
        dependencies = { 'nvim-lua/plenary.nvim', 'neovim/nvim-lspconfig' },
        ft = { 'javascript', 'typescript', 'typescriptreact', 'javascriptreact' },
        opts = function()
            return {
                config = {
                    on_attach = require('lsp').on_attach,
                },
                settings = {
                    separate_diagnostic_server = true,
                    publish_diagnostic_on = 'insert_leave',
                    expose_as_code_action = 'all',
                    tsserver_path = nil,
                    tsserver_plugins = {},
                    tsserver_max_memory = 'auto',
                    tsserver_format_options = {
                        insertSpaceAfterCommaDelimiter = true,
                        insertSpaceAfterConstructor = false,
                        insertSpaceAfterSemicolonInForStatements = true,
                        insertSpaceBeforeAndAfterBinaryOperators = true,
                        insertSpaceAfterKeywordsInControlFlowStatements = true,
                        insertSpaceAfterFunctionKeywordForAnonymousFunctions = true,
                        insertSpaceBeforeFunctionParenthesis = false,
                        insertSpaceAfterOpeningAndBeforeClosingNonemptyParenthesis = false,
                        insertSpaceAfterOpeningAndBeforeClosingNonemptyBrackets = true, -- modified
                        insertSpaceAfterOpeningAndBeforeClosingNonemptyBraces = true,
                        insertSpaceAfterOpeningAndBeforeClosingEmptyBraces = false, -- modified
                        insertSpaceAfterOpeningAndBeforeClosingTemplateStringBraces = false,
                        insertSpaceAfterOpeningAndBeforeClosingJsxExpressionBraces = false,
                        insertSpaceAfterTypeAssertion = true,
                        placeOpenBraceOnNewLineForFunctions = false,
                        placeOpenBraceOnNewLineForControlBlocks = false,
                        semicolons = 'insert',
                        indentSwitchCase = true,
                    },
                    tsserver_file_preferences = {
                        quotePreference = 'double',
                        importModuleSpecifierEnding = 'auto',
                        jsxAttributeCompletionStyle = 'auto',
                        allowTextChangesInNewFiles = true,
                        providePrefixAndSuffixTextForRename = true,
                        allowRenameOfImportPath = true,
                        includeAutomaticOptionalChainCompletions = true,
                        provideRefactorNotApplicableReason = true,
                        generateReturnInDocTemplate = true,
                        includeCompletionsForImportStatements = true,
                        includeCompletionsWithSnippetText = true,
                        includeCompletionsWithClassMemberSnippets = true,
                        includeCompletionsWithObjectLiteralMethodSnippets = true,
                        useLabelDetailsInCompletionEntries = true,
                        allowIncompleteCompletions = true,
                        displayPartsForJSDoc = true,
                        disableLineTextInReferences = true,
                        includeInlayParameterNameHints = 'none',
                        includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                        includeInlayFunctionParameterTypeHints = false,
                        includeInlayVariableTypeHints = false,
                        includeInlayVariableTypeHintsWhenTypeMatchesName = false,
                        includeInlayPropertyDeclarationTypeHints = false,
                        includeInlayFunctionLikeReturnTypeHints = false,
                        includeInlayEnumMemberValueHints = false,
                    },
                    tsserver_locale = 'en',
                    complete_function_calls = true,
                    include_completions_with_insert_text = true,
                    code_lens = 'all',
                    disable_member_code_lens = true,
                    jsx_close_tag = {
                        enable = true,
                        filetypes = { 'javascriptreact', 'typescriptreact' },
                    },
                },
            }
        end,
    },
    {
        'mfussenegger/nvim-dap',
        opts = {
            adapters = {
                ['pwa-node'] = {
                    type = 'server',
                    host = 'localhost',
                    port = '${port}',
                    executable = {
                        command = 'js-debug-adapter',
                        args = { '${port}' },
                    },
                },
            },
            configurations = {
                javascript = {
                    {
                        type = 'pwa-node',
                        request = 'launch',
                        name = 'Launch file',
                        program = '${file}',
                        cwd = '${workspaceFolder}',
                    },
                },
                typescript = {
                    {
                        type = 'pwa-node',
                        request = 'launch',
                        name = 'Launch file',
                        program = '${file}',
                        cwd = '${workspaceFolder}',
                    },
                },
            },
        },
    },
}

return {
    "stevearc/conform.nvim",
    opts = {
        -- Extend formatters_by_ft table
        formatters_by_ft = {
            -- Set the formatter for Python files to 'ruff_format'
            python = { "ruff_format" }
            -- Add a diagnostic tool for file writes (optional, linting often handled by LSP)
            -- python = { "ruff_format", "ruff"}
        },
    },
}

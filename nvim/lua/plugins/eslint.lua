return {
  "neovim/nvim-lspconfig",
  -- LSP configuration should run after Mason installs the server
  dependencies = { "mason-org/mason.nvim" },
  opts = {
    servers = {
      -- ESLint is configured to run when it detects a corresponding filetype
      eslint = {
        settings = nil,
        -- This ensures ESLint runs on save and attaches to the buffer
        on_attach = function(client, bufnr)
          vim.api.nvim.create_autocmd("BufWritePre", {
            buffer = bufnr,
            command = "EslintFixAll", -- Command to automatically fix all autofixable errors on save
          })
        end,
      },
    },
  },
}

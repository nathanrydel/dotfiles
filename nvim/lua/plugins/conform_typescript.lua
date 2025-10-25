return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      -- Use prettier for all common web filetypes
      javascript = { "prettier" },
      javascriptreact = { "prettier" },
      typescript = { "prettier" },
      typescriptreact = { "prettier" },
      json = { "prettier" },
      css = { "prettier" },
      scss = { "prettier" },
      yaml = { "prettier" },
      html = { "prettier" },
    },
    formatters = {
      -- Use prettierd if available for better performance
      prettier = {
        command = { "prettierd", "prettier" },
        args = { vim.api.nvim_buf_get_name(0) },
      },
    },
  },
}

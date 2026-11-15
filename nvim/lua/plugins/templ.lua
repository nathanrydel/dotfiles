-- GoTTH (Go + templ + Tailwind + HTMX) support for LazyVim.
-- Self-contained: stable LazyVim has no `lang.templ` extra, so this file does the
-- full job — filetype, treesitter, templ LSP, html + tailwind LSP wiring, and
-- `templ fmt` on save. Relies on the `lang.go` and `lang.tailwind` extras for
-- gopls and tailwindcss-language-server.

-- Register the .templ filetype as early as possible.
vim.filetype.add({ extension = { templ = "templ" } })

return {
  -- Treesitter parser for templ highlighting/indentation.
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed or {}, { "templ" })
    end,
  },

  -- Ensure Mason pulls the templ LSP binary.
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "templ", "html-lsp" })
    end,
  },

  -- LSP servers: templ's own server, plus html + tailwind attached to .templ.
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- templ language server (handles .templ; needs the `templ` binary on PATH).
        templ = {},

        -- HTML LSP for tag/attribute completion inside templ.
        html = { filetypes = { "html", "templ" } },

        -- Tailwind v4: treat templ as html so class="..." completions work.
        tailwindcss = {
          filetypes = { "html", "css", "templ", "javascriptreact", "typescriptreact" },
          settings = {
            tailwindCSS = {
              includeLanguages = { templ = "html" },
            },
          },
        },
      },
    },
  },

  -- Format templ files on save via `templ fmt` (conform is LazyVim's formatter).
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        templ = { "templ" },
      },
    },
  },
}

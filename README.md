# auto-lsp.nvim
- auto-lsp.nvim is an automatic configuration for mason-lspconfig.nvim and neovim/nvim-lspconfig
# Instalation
- Lazy
```lua
return{
  "pojokcodeid/auto-lsp.nvim",
  event = { "VeryLazy", "BufReadPre", "BufNewFile", "BufRead" },
  dependencies = {
    { "williamboman/mason-lspconfig.nvim" },
    {
      "neovim/nvim-lspconfig",
      cmd = {"LspInfo","LspInstall","LspUninstall"},
    },
    {
      "williamboman/mason.nvim",
      cmd = {
        "Mason",
        "MasonInstall",
        "MasonUninstall",
        "MasonUninstallAll",
        "MasonLog",
      },
    }
  },
  opts = function(_, opts)
    opts.skip_config = opts.skip_config or {}
    opts.ensure_installed = opts.ensure_installed or {}
    opts.automatic_installation = true
    opts.format_on_save = true -- config format on save none-ls
    opts.virtual_text = false
    opts.timeout_ms = 5000
    return opts
  end,
  config = function(_, opts)
    require("auto-lsp").setup(opts)
  end
}
```

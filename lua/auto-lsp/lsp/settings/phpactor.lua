return{
  cmd = { "phpactor", "language-server" },
  filetypes = { "php" },
  root_dir = require("lspconfig.util").root_pattern("composer.json", ".git",'.phpactor.json', '.phpactor.yml') or vim.loop.cwd() or vim.fn.getcwd(),
}
local M = {
  cmd = { "intelephense", "--stdio" },
  filetypes = { "php" },
  root_dir = require("lspconfig.util").root_pattern("composer.json", ".git") or vim.loop.cwd() or vim.fn.getcwd(),
  single_file_support = true,
}

-- Ambil versi PHP dari ENV secara dinamis
local function get_php_version()
  local handle = io.popen("php -v")
  if not handle then return nil end

  local result = handle:read("*a")
  handle:close()

  -- Cari pattern versi, contoh: "PHP 8.4.1"
  local version = result:match("PHP%s+(%d+%.%d+%.?%d*)")
  return version
end

local php_version = get_php_version()
if php_version then
  M.settings = {
    intelephense = {
      environment = {
        phpVersion = php_version,
      }
    }
  }
end

return M

local M = {
	cmd = { "intelephense", "--stdio" },
	filetypes = { "php" },
	root_dir = require("lspconfig.util").root_pattern("composer.json", ".git") or vim.loop.cwd() or vim.fn.getcwd(),
	single_file_support = true,
}

local function validate_php_version()
	local handle = io.popen("php -v")
	local result = handle:read("*a")
	handle:close()

	if not string.match(result, "PHP 8.4.") then
			return false
	end
	return true
end

if validate_php_version() then
	M.settings = {
			phpVersion = "8.4.1",  -- Anda bisa menyesuaikan versi ini sesuai kebutuhan
	}
end

return M

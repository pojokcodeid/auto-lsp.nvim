local ok, mason_lsp_config = pcall(require, "mason-lspconfig")
if not ok then
  return
end

local M = {}
_G.idxOf = function(array, value)
  for i, v in ipairs(array) do
    if v == value then
      return i
    end
  end
  return nil
end

M.setup = function(opts)
  mason_lsp_config.setup(opts)
  local option = {}
  require("auto-lsp.lsp.handlers").setFormtatOnSave(opts.format_on_save)
  require("auto-lsp.lsp.handlers").setVirtualText(opts.virtual_text)
  require("auto-lsp.lsp.handlers").setTimeoutMs(opts.timeout_ms)
  mason_lsp_config.setup_handlers({
    function(server_name) -- default handler (optional)
      local capabilities = require("auto-lsp.lsp.handlers").capabilities
      if server_name == "clangd" then
        capabilities.offsetEncoding = { "utf-16" }
      end
      local is_skip = false
      local my_index = idxOf(opts.skip_config, server_name)
      if my_index ~= nil then
        is_skip = true
      end
      if not is_skip then
        option = {
          on_attach = require("auto-lsp.lsp.handlers").on_attach,
          capabilities = capabilities,
        }

        server_name = vim.split(server_name, "@")[1]
        local require_ok, conf_opts = pcall(require, "auto-lsp.lsp.settings." .. server_name)
        if require_ok then
          option = vim.tbl_deep_extend("force", conf_opts, option)
        end
        require("lspconfig")[server_name].setup(option)
      end
    end,
  })
  require("auto-lsp.lsp.handlers").setup()
end

return M

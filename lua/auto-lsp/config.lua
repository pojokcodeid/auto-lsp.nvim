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
  opts.format_on_save = opts.format_on_save or true
  opts.virtual_text = opts.virtual_text or false
  opts.timeout_ms = opts.timeout_ms or 5000
  opts.skip_config = opts.skip_config or {}
  local option = {}
  -- check blink.cmp is exists
  local blink_ok, blink_cmp = pcall(require, "blink.cmp")
  if not blink_ok then
    require("auto-lsp.lsp.handlers").setFormtatOnSave(opts.format_on_save)
    require("auto-lsp.lsp.handlers").setVirtualText(opts.virtual_text)
    require("auto-lsp.lsp.handlers").setTimeoutMs(opts.timeout_ms)
  end
  local installed_servers = mason_lsp_config.get_installed_servers()
  for _, server_name in ipairs(installed_servers) do
    local capabilities
    if not blink_ok then
      capabilities = require("auto-lsp.lsp.handlers").capabilities
      if server_name == "clangd" then
        capabilities.offsetEncoding = { "utf-16" }
      end
    else
      capabilities = blink_cmp.get_lsp_capabilities({
        textDocument = {
          foldingRange = {
            dynamicRegistration = false,
            lineFoldingOnly = true,
          },
          completion = {
            completionItem = {
              snippetSupport = true,
            },
          },
        },
      })
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
      if vim.version().minor >= 11 then
        vim.lsp.config(server_name, option)
        vim.lsp.enable(server_name)
      else
        require("lspconfig")[server_name].setup(option)
      end
    end
  end
  require("auto-lsp.lsp.handlers").setup()
end

return M
